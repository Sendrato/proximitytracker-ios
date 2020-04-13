//
//  NavigationController.swift
//  LifeshareSDK
//
//  Created by Jacco Taal on 10/03/2020.
//

import Foundation
import ReactiveSwift

extension Reactive where Base: UINavigationController {
    public func push(viewController: UIViewController, animated: Bool = true) -> SignalProducer<Void, Error> {
        return SignalProducer { observer, _ in
            self.base.pushViewController(viewController, animated: animated)
            observer.sendCompleted()
        }
    }

    public func pop(animated: Bool = true) -> SignalProducer<Void, Error>  {
        return SignalProducer { observer, _ in
            self.base.popViewController(animated: true)
            observer.sendCompleted()
        }
    }
}


@objc(LSNavigationController)
open class NavigationController: UINavigationController, ViewModelPresenter {

    public var popAction: Action<(), (), Error>!

    public let factory: ViewControllerFactoryProtocol

    class EmptyFactory: ViewControllerFactoryProtocol {
        func viewController(for viewModel: ViewModel, with presenter: ViewModelPresenter) -> UIViewController? {
            return nil
        }
    }

    public convenience init() {
        self.init(factory: EmptyFactory())
    }

    public init(factory: ViewControllerFactoryProtocol) {
        self.factory = factory

        super.init(nibName: nil, bundle: nil)

        self.popAction = Action(execute: { [weak self] _ in
            return self?.dismiss() ?? .empty
        })

        let theme = LifeshareSDK.shared().theme
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = theme.barTintColor
        self.navigationBar.barStyle = theme.barStyle
        self.navigationBar.tintColor = theme.tintColor
        self.navigationBar.titleTextAttributes = [.font: theme.defaultFont(ofSize: 16, weight: .bold)]
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override open var childForStatusBarStyle: UIViewController? {
        return viewControllers.last
    }

    override open var childForStatusBarHidden: UIViewController? {
        return viewControllers.last
    }

    override open var childForHomeIndicatorAutoHidden: UIViewController? {
        return viewControllers.last
    }

    override open var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return viewControllers.last
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return viewControllers.first?.preferredInterfaceOrientationForPresentation ?? .portrait
    }

    open override var shouldAutorotate: Bool {
        return viewControllers.first?.shouldAutorotate ?? false
    }

    open func present(viewModel: ViewModel) -> SignalProducer<Void, Error> {
        if let vc = self.factory.viewController(for: viewModel, with: self) {
            return self.reactive.push(viewController: vc, animated: true)
        }
        return SignalProducer(error: NoViewControllerProgrammingError())
    }

    open func dismiss() -> SignalProducer<Void, Error> {
        self.popViewController(animated: true)
        return SignalProducer.empty
    }
}
