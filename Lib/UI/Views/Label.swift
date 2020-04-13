//
//  Label.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 14/02/2020.
//  Copyright © 2020 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

public extension UILabel {
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }

    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    func setText(_ s: String?) -> Self {
        self.text = s
        return self
    }

    func numberOfLines(_ n: Int) -> Self {
        self.numberOfLines = n
        return self
    }

    func lineBreakMode(_ m: NSLineBreakMode) -> Self {
        self.lineBreakMode = m
        return self
    }


    func textAlignment(_ a: NSTextAlignment) -> Self {
        self.textAlignment = a
        return self
    }
}

public extension Theme {
    func label() -> UILabel {
        return label(size: nil)
    }

    func label(size: CGFloat?) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = foregroundColor
        label.font = defaultFont(ofSize: size ?? defaultFontSize, weight: .regular)
        return label
    }

    func titleLabel(_ s: String? = nil) -> UILabel {
        return self.label()
            .font(self.defaultFont(ofSize: defaultFontSize * 1.4, weight: .bold))
            .setText(s)
    }


    func subtitleLabel(_ s: String? = nil) -> UILabel {
        return self.label()
            .font(self.defaultFont(ofSize: defaultFontSize * 1.2, weight: .bold))
            .setText(s)
    }

    func primaryLabel(_ s: String? = nil) -> UILabel {
        return self.label()
            .font(self.defaultFont(ofSize: defaultFontSize * 1.2, weight: .semibold))
            .setText(s)
    }

    func secondaryLabel(_ s: String? = nil) -> UILabel {
        return self.label()
            .font(self.defaultFont(ofSize: defaultFontSize * 0.9, weight: .regular))
            .setText(s)
    }

    func tertiaryLabel(_ s: String? = nil) -> UILabel {
        return self.label()
            .font(self.defaultFont(ofSize: defaultFontSize * 0.8, weight: .light))
            .setText(s)
    }

    func buttonLabel(_ s: String? = nil) -> UILabel {
        return self.label()
            .font(self.defaultFont(ofSize: defaultFontSize * 1.1, weight: .semibold))
            .setText(s)
            .textAlignment(.center)
    }

}
