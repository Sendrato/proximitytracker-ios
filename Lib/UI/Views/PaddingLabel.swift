//
//  PaddingLabel.swift
//  Sportlink
//
//  Created by Jacco Taal on 03/10/2018.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable public class PaddingLabel: UILabel {

    @IBInspectable var insets = UIEdgeInsets(top: 4.0, left: 4.0, bottom: 4.0, right: 4.0)

    override public func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    override public var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + insets.left + insets.right,
                      height: size.height + insets.top + insets.bottom)
    }
}
