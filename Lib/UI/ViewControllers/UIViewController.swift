//
//  ViewController.swift
//  LifeshareSDK
//
//  Created by Jacco Taal on 10/03/2020.
//

import Foundation
import ReactiveSwift

extension Reactive where Base: UIViewController {
    public func present(viewController: UIViewController, animated: Bool = true) -> SignalProducer<Void, Error> {
        return SignalProducer { observer, _ in
            self.base.present(viewController, animated: animated, completion: {
                observer.sendCompleted()
            })
        }
    }

    public func dismiss(animated: Bool = true) -> SignalProducer<Void, Error> {
        return SignalProducer { observer, _ in
            self.base.dismiss(animated: animated) {
                observer.sendCompleted()
            }
        }
    }

    public var dismissAction: Action<(), (), Error> {
        return Action(execute: { _ -> SignalProducer<Void, Error> in
            return self.dismiss(animated: true)
        })
    }
}
