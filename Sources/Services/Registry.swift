//
//  File.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 13/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import Foundation

class Registry {

    var pending: [TracingCrypto.RollingProximityIdentifier]

    init() {
        pending = []
    }

    func add(entry: TracingCrypto.RollingProximityIdentifier) {
        pending.append(entry)
    }
}
