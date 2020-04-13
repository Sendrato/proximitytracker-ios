//
//  UITableView-Swift.swift
//  Vidacle
//
//  Created by Jacco Taal on 17/12/2018.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

protocol ReusableView: class {
    static func reuseIdentifier() -> String
}

extension ReusableView {
    static func reuseIdentifier() -> String {
        return NSStringFromClass(self)
    }
}

@objc
extension UITableViewCell: ReusableView {
}

@objc
extension UITableViewHeaderFooterView: ReusableView {
}

@objc
extension UITableView {

    func register(_ type: UITableViewCell.Type, with nib: UINib) {
        register(nib, forCellReuseIdentifier: type.reuseIdentifier())
    }

    func register(_ type: UITableViewCell.Type) {
        register(type, forCellReuseIdentifier: type.reuseIdentifier())
    }

    @nonobjc
    func register(_ type: UITableViewHeaderFooterView.Type, with nib: UINib) {
        register(nib, forHeaderFooterViewReuseIdentifier: type.reuseIdentifier())
    }

    @nonobjc
    func register(_ type: UITableViewHeaderFooterView.Type) {
        register(type, forHeaderFooterViewReuseIdentifier: type.reuseIdentifier())
    }

    @nonobjc
    func dequeue<T: UITableViewCell>(_ type: T.Type,
                                     for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withIdentifier: type.reuseIdentifier(),
                                       for: indexPath)
        guard let cellT = cell as? T else {
            fatalError("Dequeue failed, expect: \(type) was: \(cell)")
        }

        return cellT
    }

    @nonobjc
    func dequeue<T: UITableViewHeaderFooterView>(_ type: T.Type) -> T {
        let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: type.reuseIdentifier())
        guard let headerFooterViewT = headerFooterView as? T else {
            fatalError("Dequeue failed, expect: \(type) was: \(String(describing: headerFooterView))")
        }

        return headerFooterViewT
    }
}
