//
//  CoverGradientOverlay.swift
//  LifeshareSDK
//
//  Created by Jacco Taal on 09/03/2020.
//

import Foundation
import UIKit

public class CoverGradientOverlay: UIView {

    public override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        if let layer = self.layer as? CAGradientLayer {
            layer.colors = [
                UIColor(white: 0, alpha: 0.2).cgColor,
                UIColor(white: 0, alpha: 0.0).cgColor,
                UIColor(white: 0, alpha: 0.0).cgColor,
                UIColor(white: 0, alpha: 0.3).cgColor,
            ]
            layer.locations = [0.0, 0.2, 0.6, 1.0].map { NSNumber(floatLiteral: $0) }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
