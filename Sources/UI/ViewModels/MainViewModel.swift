//
//  File.swift
//  Rid Covid 19
//
//  Created by Jacco Taal on 13/04/2020.
//  Copyright © 2020 Bitnomica. All rights reserved.
//

import Foundation
import ReactiveSwift

class MainViewModel {

    var joinAction: Action<(), (), Error>

    var tracking: Property<Bool>

    init() {
        let tracker = Tracker.main
        joinAction = Action(execute: { _ in
            tracker.join()
            return .empty
        })

        tracking = Property(tracker.tracking)
    }

}
