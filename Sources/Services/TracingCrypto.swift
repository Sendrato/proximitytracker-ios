//
//  Crypto.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 15/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import Foundation
import CryptoSwift

class TracingCrypto {

    struct TracingKey {
        let tracingKey: [UInt8]
    }

    typealias DailyTracingKey = HKDF

    struct RollingProximityIdentifier {
        let id: [UInt8]
    }
    let tracingKey: TracingKey

    enum Error: Swift.Error {
        case couldNotStoreKey
        case invalidTracingKey
        case invalidDailyTracingKey
        case invalidRollingProximityKey
    }

    init() throws {

        let tag = "com.dexels.proximtytracker".data(using: .utf8)!
        let getQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
                                       kSecReturnRef as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            try tracingKey = Self.genTracingKey()

            let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: tag,
                                           kSecValueRef as String: tracingKey.tracingKey.toBase64()!]
            let status = SecItemAdd(addquery as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw Error.couldNotStoreKey
            }
            return
        }
        let key = item as! String
        tracingKey = TracingKey(tracingKey: key.bytes)
    }


    public static func genTracingKey() throws -> TracingKey {

        var bytes = [UInt8](repeating: 0, count: 32)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        if status == errSecSuccess { // Always test the status.
            print(bytes)
            return TracingKey(tracingKey: bytes)
        }
        throw Error.invalidTracingKey
    }

    public func dailyTracingKey(day: Int) throws -> DailyTracingKey {
        let info: String = "CT-DTK\(day)"
        return try CryptoSwift.HKDF(password: tracingKey.tracingKey, salt: nil, info: info.data(using: .utf8)!.bytes, keyLength: 16)
    }


    public func rollingProximityIdentifier(day: Int, tin: UInt) throws -> RollingProximityIdentifier {
        let str = "CT-RPI\(tin)"
        let hash = try HMAC(key: dailyTracingKey(day: day).calculate(), variant: .sha256).authenticate(str.data(using: .utf8)!.bytes)
        if hash.count < 16 {
            throw Error.invalidRollingProximityKey
        }
        return RollingProximityIdentifier(id: Array(hash[0..<16]))
    }
}
