//
//  File.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 06/12/2019.
//  Copyright © 2019 Vidacle B.V. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

public class TextField: UITextField, Themeable {
    let size: ThemeableSize
    required convenience public init(theme: Theme) {
        self.init(theme: theme, size: .regular)
    }

    public required init(theme: Theme, size: ThemeableSize) {
        self.size = size

        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        switch size {
        case .large:
            font = theme.defaultFont(ofSize: 18, weight: .medium)
        case .regular:
            font = theme.defaultFont(ofSize: 14, weight: .medium)
        case .small:
            font = theme.defaultFont(ofSize: 12, weight: .medium)
        }

        textColor = theme.textInputColor
        backgroundColor = theme.textFieldBackgroundColor
        borderStyle = .line
        layer.cornerRadius = size == .large ? 6 : 4
        layer.masksToBounds = true
    }

    var insetMargin: CGFloat {
        size == .regular ? 4 : (size == .large ? 8 : 4)
    }

    // placeholder position
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return super.textRect(forBounds: bounds).insetBy(dx: insetMargin, dy: insetMargin)
    }

    // text position
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return super.editingRect(forBounds: bounds).insetBy(dx: insetMargin, dy: insetMargin)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        //let size = super.intrinsicContentSize
        return CGSize(width: UIView.noIntrinsicMetric, height: size == .regular ? 32 : (size == .large ? 44 : 28))
    }
}


extension Theme {

    func textField(size: ThemeableSize = .regular) -> TextField {
        return TextField(theme: self, size: size)
    }

    func textFieldTitleLabel(size: ThemeableSize = .regular) -> UILabel {
        let label = self.label()
        label.textColor = foregroundColor
        label.font = defaultFont(ofSize: size == .large ? 15 : 13, weight: .medium)
        return label
    }

    func validationMessagelabel(size: ThemeableSize = .regular) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = negativeColor
        label.font = defaultFont(ofSize: size == .large ? 13 : defaultFontSize * 0.72, weight: .regular)
        return label
    }

}
