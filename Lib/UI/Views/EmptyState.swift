//
//  EmptyState.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 18/02/2020.
//  Copyright © 2020 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit
import ReactiveSwift

public class EmptyStateViewModel {
    public let title: Property<String>
    public let subtitle: Property<String?>

    public init(title: String, subtitle: String?) {
        self.title = Property(value: title)
        self.subtitle = Property(value: subtitle)
    }
}

public class EmptyStateView: UIView, Themeable {

    public let title: UILabel
    public let subtitle: UILabel

    convenience init() {
        self.init(theme: LifeshareSDK.shared().theme)
    }

    required public init(theme: Theme) {
        title = theme.label()
            .font(theme.defaultFont(ofSize: 13, weight: .bold))
            .textColor(.gray)
            .defaultShadow()
            .numberOfLines(0)
            .lineBreakMode(.byWordWrapping)

        subtitle = theme.subtitleLabel()
            .textColor(.gray)
            .defaultShadow()
            .numberOfLines(0)
            .lineBreakMode(.byWordWrapping)

        super.init(frame: .zero)

        let stack = UIStackView(arrangedSubviews: [title, subtitle])
            .axis(.vertical)
            .alignment(.center)
            .spacing(4)
            .distribution(.equalSpacing)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [
            stack.topAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.bottomAnchor),
            stack.leftAnchor.constraint(greaterThanOrEqualTo: self.layoutMarginsGuide.leftAnchor),
            stack.rightAnchor.constraint(lessThanOrEqualTo: self.layoutMarginsGuide.rightAnchor),
        ]
        for cons in constraints {
            cons.priority = .defaultLow
            cons.isActive = true
        }

        stack.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        stack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stack.setNeedsLayout()

        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ viewModel: EmptyStateViewModel) {
        title.reactive.text <~ viewModel.title.map { $0.uppercased() }
        subtitle.reactive.text <~ viewModel.subtitle
    }
}
