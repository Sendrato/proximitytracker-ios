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

    typealias DailyTracingKey = Array<UInt8>

    struct RollingProximityIdentifier: Hashable {
        let id: [UInt8]

        var data: Data {
            return Data(id)
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    enum Error: Swift.Error {
        case couldNotStoreKey
        case invalidTracingKey
        case invalidDailyTracingKey
        case invalidRollingProximityKey
    }

    let tracingKey: TracingKey

    static let keyChainTag = "com.dexels.proximtytracker"

    init() throws {

        let tag = Self.keyChainTag.data(using: .utf8)!
        let getQuery: [String: Any] = [kSecClass as String: kSecClassKey,
                                       kSecAttrApplicationTag as String: tag,
                                       kSecReturnRef as String: true]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(getQuery as CFDictionary, &item)
        guard status == errSecSuccess else {
            try tracingKey = Self.genTracingKey()

            let addquery: [String: Any] = [kSecClass as String: kSecClassKey,
                                           kSecAttrApplicationTag as String: tag,
                                           kSecValueRef as String: tracingKey.tracingKey.toHexString()]

            let status = SecItemAdd(addquery as CFDictionary, nil)

            guard status == errSecSuccess else {
                print("Could not save token")
                //                throw Error.couldNotStoreKey
                return 
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
            return TracingKey(tracingKey: bytes)
        }
        throw Error.invalidTracingKey
    }

    private var dailyKeys = [Int: DailyTracingKey]()

    public func dailyTracingKey(day: Int) throws -> DailyTracingKey {
        if let key = dailyKeys[day] {
            return key
        }
        let info: String = "CT-DTK\(day)"
        let key = try CryptoSwift.HKDF(password: tracingKey.tracingKey, salt: nil, info: info.data(using: .utf8)!.bytes, keyLength: 16).calculate()
        dailyKeys[day] = key
        return key
    }

    public func rollingProximityIdentifier(day: Int, tin: Int) throws -> RollingProximityIdentifier {
        let str = "CT-RPI\(tin)"
        let hash = try HMAC(key: dailyTracingKey(day: day), variant: .sha256).authenticate(str.data(using: .utf8)!.bytes)
        if hash.count < 16 {
            throw Error.invalidRollingProximityKey
        }
        return RollingProximityIdentifier(id: Array(hash[0..<16]))
    }

    public func check(suspiciousTokens: Set<RollingProximityIdentifier>,
                      discoveredTokens: Set<RollingProximityIdentifier>) -> [RollingProximityIdentifier] {
        var found = [RollingProximityIdentifier]()
        for token in suspiciousTokens {
            if discoveredTokens.contains(token) {
                found.append(token)
            }
        }
        return found
    }
}
