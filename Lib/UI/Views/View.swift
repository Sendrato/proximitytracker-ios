//
//  View.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 17/02/2020.
//  Copyright © 2020 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {

    @discardableResult
    func defaultShadow() -> Self {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.5
        return self
    }

    func wrapped(edgeInsets: UIEdgeInsets) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        self.embed(inView: view, edgeInsets: edgeInsets)
        return view
    }

    func wrappedBetweenMargins(edgeInsets: UIEdgeInsets) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        self.embedInMargins(of: view, edgeInsets: edgeInsets)
        return view
    }


    func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    func tintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
}

public extension UIEdgeInsets {
    static func same(_ constant: CGFloat) -> Self {
        return Self(top: constant, left: constant, bottom: constant, right: constant)
    }
    static func vertical(_ constant: CGFloat, horizontal: CGFloat) -> Self {
        return Self(top: constant, left: horizontal, bottom: constant, right: horizontal)
    }
}
