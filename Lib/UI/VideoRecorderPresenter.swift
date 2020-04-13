//
//  VideoRecorderPresenter.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 06-06-18.
//  Copyright © 2018 Vidacle B.V. All rights reserved.
//

import Foundation
import ReactiveSwift

@objc
public class VideoRecorderPresenter: NSObject {
    let recorderWindow: UIWindow
    weak var mainWindow: UIWindow?

    @objc var isPresenting: Bool

    @objc
    public init(mainWindow: UIWindow) {
        self.mainWindow = mainWindow
        self.recorderWindow = UIWindow(frame: UIScreen.main.bounds)
        self.recorderWindow.windowLevel = UIWindow.Level(rawValue: -1)
        self.recorderWindow.isHidden = true
        self.isPresenting = false
        super.init()
    }

    private func show(completion: @escaping (Bool) -> Void) {
        self.recorderWindow.isHidden = false
        self.recorderWindow.rootViewController?.view.frame = self.recorderWindow.bounds
        self.recorderWindow.makeKeyAndVisible()
        UIView.animate(withDuration: 0, animations: {
            self.mainWindow?.alpha = 0.0
        }, completion: { (finished) in
            if (finished) {
               // self.recorderWindow.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                self.mainWindow?.isHidden = true
                self.isPresenting = true
            }
            completion(finished)
        })
    }

    @objc
    public func presentRecorder(viewModel: LSVideoRecorderViewModel, animated: Bool = false, completion: (() -> Void)?) {
        let recorder = LSVideoRecorderViewController(viewModel: viewModel)

        viewModel.closeCommand.executionSignals.subscribeNext { _ in
            self.hideRecorder(animated: true, completion: nil)
        }

        self.recorderWindow.rootViewController = recorder

        show { finished -> Void in
            if finished {
                if completion != nil {
                    completion!()
                }
            }
        }
    }

    @objc
    public func hideRecorder(animated: Bool, completion: (() -> Void)? ) {
        self.mainWindow?.isHidden = false
        self.mainWindow?.alpha = 0.0
        UIView.animate(withDuration: 0.7, animations: {
            self.mainWindow?.alpha = 1.0
        }) { (finished) in
            if (finished) {
                self.mainWindow?.makeKey()
                self.recorderWindow.isHidden = true
                self.recorderWindow.rootViewController = nil
                self.mainWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                self.isPresenting = false

                if completion != nil {
                    completion!()
                }
            }
        }
    }

    public func present(viewModel: LSVideoRecorderViewModel, animated: Bool = false) -> SignalProducer<(), Error> {
        return SignalProducer { observer, lifetime in
            self.presentRecorder(viewModel: viewModel, animated: animated, completion: {
                observer.sendCompleted()
            })
        }
    }
}
