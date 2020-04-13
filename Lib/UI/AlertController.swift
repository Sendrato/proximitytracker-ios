//
//  AlertController.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 12-09-18.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import ReactiveCocoa


extension UIAlertController {

    @objc
    public static func alertController(title: String, message: String, withButton: String,
                                handler: @escaping (_ controller: UIAlertController, _ name: UIAlertAction) -> Void ) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: LSLocalizedString(withButton), style: .default, handler: {action in
            handler(alert, action)
        }))
        return alert
    }
}

extension UIView {
    func searchVisualEffectsSubview() -> UIVisualEffectView? {
        if let visualEffectView = self as? UIVisualEffectView {
            return visualEffectView
        } else {
            for subview in subviews {
                if let found = subview.searchVisualEffectsSubview() {
                    return found
                }
            }
        }

        return nil
    }
}
