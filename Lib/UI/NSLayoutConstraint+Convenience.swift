//
//  NSLayoutConstraint+Convenience.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 07-06-18.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import UIKit

extension NSLayoutConstraint {

    @objc
    public static func width(view: UIView, width: CGFloat) -> NSLayoutConstraint {
        return
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute,
                               multiplier: 1.0, constant: width)
    }

    @objc
    public static func height(view: UIView, height: CGFloat) -> NSLayoutConstraint {
        return
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal,
                               toItem: nil, attribute: .notAnAttribute,
                               multiplier: 1.0, constant: height)
    }

    @objc
    public static func size(view: UIView, size: CGSize) -> [NSLayoutConstraint] {
        return [
            width(view: view, width: size.width),
            height(view: view, height: size.height)
        ]
    }

    @objc
    public static func fill(view: UIView, spacing: CGFloat = 0) -> [NSLayoutConstraint] {
        return hFill(view: view, spacing: spacing) + vFill(view: view, spacing: spacing)
    }

    @objc
    public static func hFill(view: UIView, spacing: CGFloat = 0) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: "H:|-spacing-[view]-spacing-|",
                                              options: [], metrics: ["spacing": spacing], views: ["view": view])
    }

    @objc
    public static func vFill(view: UIView, spacing: CGFloat = 0) -> [NSLayoutConstraint] {
        return NSLayoutConstraint.constraints(withVisualFormat: "V:|-spacing-[view]-spacing-|",
                                              options: [], metrics: ["spacing": spacing], views: ["view": view])
    }

    @objc
    public static func align(views: [UIView], attribute: NSLayoutConstraint.Attribute) -> [NSLayoutConstraint] {
        guard let first = views.first else {
            return []
        }

        return views[1...views.count-1].compactMap({ view in
            return NSLayoutConstraint(item: view, attribute: attribute, relatedBy: .equal, toItem: first,
                                      attribute: attribute, multiplier: 1.0, constant: 0)
        })
    }

    @objc
    public static func aspectRatio(view: UIView, ratio: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: ratio, constant: 0)
    }
}
