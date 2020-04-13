//
//  UIView+fromNib.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 04/12/2018.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    @discardableResult
    func fromNib<T: UIView>(in bundle: Bundle? = nil) -> T? {
        let bundle = bundle ?? Bundle(for: type(of: self))
        guard let contentView = bundle.loadNibNamed(String(describing: type(of: self)),
                                                    owner: self, options: nil)?.first as? T else {
                                                        // xib not loaded, or its top view is of the wrong type
                                                        return nil
        }
        self.addSubview(contentView)
        self.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.embed(inView: self)
        contentView.setNeedsLayout()
        return contentView
    }

    @discardableResult
    @objc
    public func unsafeFromNib(in bundle: Bundle? = nil) -> UIView? {
        return fromNib(in: bundle)
    }

    @objc
    public func embed(inView: UIView, margin: CGFloat = 0.0) {
        embed(inView: inView, edgeInsets: UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin))
    }

    @objc
    public func embed(inView: UIView, edgeInsets: UIEdgeInsets) {
        self.frame = inView.bounds.inset(by: edgeInsets)
        self.translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: inView.topAnchor, constant: edgeInsets.top).isActive = true
        leftAnchor.constraint(equalTo: inView.leftAnchor, constant: edgeInsets.left).isActive = true
        rightAnchor.constraint(equalTo: inView.rightAnchor, constant: -edgeInsets.right).isActive = true
        bottomAnchor.constraint(equalTo: inView.bottomAnchor, constant: -edgeInsets.bottom).isActive = true
    }

    @objc
    public func embedInMargins(of inView: UIView, edgeInsets: UIEdgeInsets) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let guides = inView.layoutMarginsGuide
        self.frame = guides.layoutFrame.inset(by: edgeInsets)
        topAnchor.constraint(equalTo: guides.topAnchor, constant: edgeInsets.top).isActive = true
        leftAnchor.constraint(equalTo: guides.leftAnchor, constant: edgeInsets.left).isActive = true
        rightAnchor.constraint(equalTo: guides.rightAnchor, constant: -edgeInsets.right).isActive = true
        bottomAnchor.constraint(equalTo: guides.bottomAnchor, constant: -edgeInsets.bottom).isActive = true
    }

    @available(iOS 11.0, *)
    @objc
    public func safeEmbed(inView: UIView, edgeInsets: UIEdgeInsets) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = inView.bounds.inset(by: edgeInsets)
        let guide = inView.safeAreaLayoutGuide;
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: guide.topAnchor, constant: edgeInsets.top),
            leftAnchor.constraint(equalTo: guide.leftAnchor, constant: edgeInsets.left),
            rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -edgeInsets.right),
            bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -edgeInsets.bottom)
        ])
    }

    public func aspectFit(inView: UIView, widthToHeightRatio ratio: CGFloat) {
        self.translatesAutoresizingMaskIntoConstraints = false

        let widthFit = widthAnchor.constraint(equalTo: inView.widthAnchor, constant: 1.0)
        widthFit.priority = .init(rawValue: 750)
        let heightFit = heightAnchor.constraint(equalTo: inView.heightAnchor, constant: 1.0)
        heightFit.priority = .init(rawValue: 750)

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: inView.centerXAnchor, constant: 0),
            centerYAnchor.constraint(equalTo: inView.centerYAnchor, constant: 0),
            widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio),
            widthFit, heightFit,
            widthAnchor.constraint(lessThanOrEqualTo: inView.widthAnchor),
            heightAnchor.constraint(lessThanOrEqualTo: inView.heightAnchor)
        ])

    }

}
