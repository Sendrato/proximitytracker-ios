//
//  ValidatedTextField.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 11/12/2019.
//  Copyright © 2019 Vidacle B.V. All rights reserved.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift

public class ValidatedTextField: UIControl, Themeable {

    public let textField: TextField
    public let titleLabel: UILabel
    public let validationTextLabel: UILabel

    private let stackView: UIStackView
    fileprivate let theme: Theme

    required public convenience init(theme: Theme) {
        self.init(theme: theme, size: .regular)
    }

    required public init(theme: Theme, size: ThemeableSize) {
        self.theme = theme
        textField = theme.textField(size: size)
        titleLabel = theme.textFieldTitleLabel(size: size)
        validationTextLabel = theme.validationMessagelabel(size: size)

        stackView = UIStackView(arrangedSubviews: [titleLabel, textField, validationTextLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        addSubview(stackView)
        stackView.embed(inView: self, edgeInsets: UIEdgeInsets(top: 4, left: 0, bottom: 6, right: 0))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension Reactive where Base: ValidatedTextField {

    public var text: BindingTarget<String?> {
        return self.base.textField.reactive.text
    }

    public var title: BindingTarget<String?> {
        return makeBindingTarget { $0.titleLabel.text = $1 }
    }

    public var validationText: BindingTarget<String?> {
        return makeBindingTarget { $0.validationTextLabel.text = $1 }
    }

    public var textFieldBorderColor: BindingTarget<UIColor?> {
        return makeBindingTarget {
            $0.textField.layer.borderColor = $1?.cgColor
            $0.textField.layer.borderWidth = ($1 == nil) ? 0.0 : 1.0
        }
    }

    public var continuousTextValue: Signal<String, Never> {
        return base.textField.reactive.continuousTextValues
    }

    public var continuousAttributedTextValue: Signal<NSAttributedString, Never> {
        return base.textField.reactive.continuousAttributedTextValues
    }

    public func set<E: Error>(validatingProperty prop: ValidatingProperty<String, E>) {
        base.textField.text = prop.result.value.value

        prop <~ base.textField.reactive.continuousTextValues

            validationText <~ prop.result.producer.map { result -> String? in
            switch result {
            case .coerced, .valid:
                return nil
            case .invalid(let value, let error):
                if value.isEmpty {
                    return nil
                }
                return error.localizedDescription
            }
        }
        .animateEach(duration: 0.5, curve: .easeInOut)
        .flatten(.merge)

        textFieldBorderColor <~ prop.result.producer.map { result -> UIColor? in
            switch result {
            case .coerced, .valid:
                return self.base.theme.positiveColor
            case .invalid(let value, _):
                if value.isEmpty {
                    return self.base.theme.foregroundColor
                }
                return self.base.theme.negativeColor
            }
        }
        .animateEach(duration: 0.3, curve: .easeInOut)
        .flatten(.merge)
    }
}

public extension ValidatedTextField {
    enum NotEmptyValidationError: LocalizedError, Validator {
        public static let bundle = Bundle.main

        case empty

        public static func validate(value: String) -> ValidatingProperty<String, Self>.Decision {
            return value.count > 0 ? .valid : .invalid(.empty)
        }
    }
}


public extension Reactive where Base: UIControl {

    func next(control: UIControl) -> Reactive<UIControl> {
        let signal: Signal<(), Never>
        if let base = base as? ValidatedTextField {
            signal = base.textField.reactive.mapControlEvents(.editingDidEnd) { _ in () }
        } else {
            signal = mapControlEvents(.editingDidEnd) { _ in () }
        }
        if let control = control as? ValidatedTextField {
            control.textField.reactive.becomeFirstResponder <~ signal
        } else {
            control.reactive.becomeFirstResponder <~ signal
        }
        return control.reactive
    }

    func nextResign() {
        base.reactive.resignFirstResponder <~ mapControlEvents(.editingDidEnd) { _ in () }
    }
}


public protocol Validator {
    associatedtype Error: Swift.Error

    static func property() -> ValidatingProperty<String, Error>

    static func validate(value: String) -> ValidatingProperty<String, Error>.Decision
}

public extension Validator {

    static func property() -> ValidatingProperty<String, Error> {
        return ValidatingProperty("", self.validate)
    }
}
