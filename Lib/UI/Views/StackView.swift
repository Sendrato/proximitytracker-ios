//
//  StackView.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 17/02/2020.
//  Copyright © 2020 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

public extension UIStackView {

    func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
       self.axis = axis
       return self
    }

    func alignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }

    func distribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }

    static func defaultVStack(arrangedSubviews: [UIView]) -> Self {
        return Self.init(arrangedSubviews: arrangedSubviews)
            .axis(.vertical)
            .alignment(.fill)
            .spacing(16)
            .distribution(.equalSpacing)
    }

    static func defaultFormStack(arrangedSubviews: [UIView]) -> Self {
        return Self.defaultVStack(arrangedSubviews: arrangedSubviews)
            .spacing(8)
    }


}

public extension UIView {

    static func vspacer(_ c: CGFloat) -> Self {

        let spacer = Self.init(frame: CGRect(x: 0, y: 0, width: 1, height: c))
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: c).isActive = true
        return spacer
    }

    static func hspacer(_ c: CGFloat) -> Self {

        let spacer = Self.init(frame: CGRect(x: 0, y: 0, width: c, height: 1))
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.widthAnchor.constraint(equalToConstant: c).isActive = true
        return spacer
    }
}
