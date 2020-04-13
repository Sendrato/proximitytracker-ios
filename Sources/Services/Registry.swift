//
//  File.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 13/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import Foundation

class Registry {
    typealias Token = UUID

    struct Entry: Codable {
        struct Location: Codable {
            let lat, long: Double
        }
        var uuid: Token
        var location: Location
    }

    // todo make threadsafe
    var pending: [Entry]

    var tokens: [Token]

    init() {
        pending = []
        tokens = []
    }

    func add(entry: Entry) {
        pending.append(entry)
    }

    func add(token: Token) {
        tokens.append(token)
    }

    func newToken() -> Token {
        return Token()
    }
}
