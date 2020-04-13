//
//  Pill.swift
//  Alamofire
//
//  Created by Jacco Taal on 09/03/2020.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa

public class Pill: UIButton {
    let label: UILabel

    var textColor: UIColor {
        get {
            label.textColor
        }
        set {
            label.textColor = newValue
        }
    }

    let labelEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

    init(_ s: String? = nil,  theme: Theme) {
        label = theme.buttonLabel(s)

        super.init(frame: .zero)

        addSubview(label)
        label.embed(inView: self, edgeInsets: labelEdgeInsets)

        reactive.signal(for: \.isEnabled).observeValues { state in
            self.label.textColor = self.isEnabled ? theme.foregroundColor : theme.inactiveForegroundColor
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = frame.height / 2
    }

    func textColor(_ c: UIColor) -> Self {
        self.textColor = c
        return self
    }

    func borderColor(_ c: UIColor) -> Self {
        self.layer.borderColor = c.cgColor
        self.layer.borderWidth = 1.0
        return self
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: label.intrinsicContentSize.width + labelEdgeInsets.left + labelEdgeInsets.right,
                      height: label.intrinsicContentSize.height + labelEdgeInsets.top + labelEdgeInsets.bottom)
    }
}

public class RoundButton: UIButton {

    public init() {
        super.init(frame: .zero)
        imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)

        widthAnchor.constraint(equalTo: heightAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2.0
    }
}


public extension Theme {

    func primaryButton(_ s: String? = nil) -> Pill {
        return Pill(s, theme: self)
            .backgroundColor(self.primaryControlColor)
            .textColor(self.primaryControlTextColor)
    }

    func secondaryButton(_ s: String? = nil) -> Pill {
        return Pill(s, theme: self)
            .backgroundColor(UIColor(white: 0, alpha: 0.3))
            .textColor(secondaryControlTextColor)
            .borderColor(secondaryControlColor)
    }
}
