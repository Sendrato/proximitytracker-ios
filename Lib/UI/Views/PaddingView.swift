//
//  PaddingView.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 23/09/2019.
//  Copyright © 2019 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

public class PaddingView: UIView {

    public init(wrapping: UIView, spacing: CGFloat = 16.0) {
        super.init(frame: .zero)

        addSubview(wrapping)
        translatesAutoresizingMaskIntoConstraints = false
        wrapping.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.fill(view: wrapping, spacing: spacing))
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
