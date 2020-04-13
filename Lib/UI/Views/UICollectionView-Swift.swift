//
//  UICollectionView-Swift.swift
//  Vidacle
//
//  Created by Jacco Taal on 17/12/2018.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

@objc
extension UICollectionReusableView: ReusableView {
}

@objc
public extension UICollectionView {

   func register(_ type: UICollectionViewCell.Type, with nib: UINib) {
        register(nib, forCellWithReuseIdentifier: type.reuseIdentifier())
    }

    func register(_ type: UICollectionViewCell.Type) {
        register(type, forCellWithReuseIdentifier: type.reuseIdentifier())
    }

    @nonobjc
    func register(_ type: UICollectionReusableView.Type, for kind: String, with nib: UINib) {
        register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: type.reuseIdentifier())
    }

    @nonobjc
    func register(_ type: UICollectionReusableView.Type, for kind: String) {
        register(type, forSupplementaryViewOfKind: kind, withReuseIdentifier: type.reuseIdentifier())
    }

    @nonobjc
    func dequeue<T: UICollectionViewCell>(_ type: T.Type,
                                          for indexPath: IndexPath) -> T {
        let cell = dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier(),
                                       for: indexPath)
        guard let cellT = cell as? T else {
            fatalError("Dequeue failed, expect: \(type) was: \(cell)")
        }

        return cellT
    }

    @nonobjc
    func dequeue<T: UICollectionReusableView>(_ type: T.Type, of kind: String, for indexPath: IndexPath) -> T {
        let supplementaryView = dequeueReusableSupplementaryView(ofKind: kind,
                                                                 withReuseIdentifier: type.reuseIdentifier(),
                                                                 for: indexPath)
        guard let view = supplementaryView as? T else {
            fatalError("Dequeue failed, expect: \(type) was: \(String(describing: supplementaryView))")
        }

        return view
    }

    func isNotCellReused(cell: UICollectionViewCell, at indexPath: IndexPath) -> Bool {
        let _cell = cellForItem(at: indexPath)
        return _cell == nil || _cell == cell
    }
}
