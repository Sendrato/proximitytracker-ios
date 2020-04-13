//
//  CollectionViewController.swift
//  LifeshareSDK
//
//  Created by Jacco Taal on 19/02/2020.
//

import Foundation
import ReactiveCocoa
import ReactiveSwift
import os

open class CollectionViewController<Bridge: CollectionViewDataSourceBridge>: UICollectionViewController {

    var bridge: Bridge!

    convenience public init(dataSources: [DataSourceProtocol], presenter: ViewModelPresenter, emptyState: EmptyStateViewModel? = nil, theme: Theme = LifeshareSDK.shared().theme) {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 320, height: 90)
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0
        layout.sectionInset = .zero

        self.init(dataSources: dataSources, presenter: presenter, emptyState: emptyState, layout: layout, theme: theme)
    }


    public init(dataSources: [DataSourceProtocol], presenter: ViewModelPresenter, emptyState: EmptyStateViewModel? = nil, layout: UICollectionViewLayout, theme: Theme = LifeshareSDK.shared().theme) {

        let refreshControl = UIRefreshControl()

        super.init(collectionViewLayout: layout)
        let collectionView = theme.collectionView(collectionViewLayout: layout)
        self.collectionView = collectionView

        refreshControl.tintColor = theme.tintColor
        refreshControl.attributedTitle = NSAttributedString(string: LSLocalizedString("refresh__refreshing"), attributes: [.foregroundColor: UIColor.white])


        refreshControl.reactive.refresh = CocoaAction(Action<Void, Void, Swift.Error> (execute: { _ in
            var producers = [SignalProducer<Void, Swift.Error>]()
            for dataSource in dataSources {
                producers.append(dataSource.fetch(page: 0, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
            }
            return SignalProducer.zip(producers).map { _ in return () }.on(failed: { error in
                refreshControl.endRefreshing()
                LifeshareSDK.shared().publish(UINotification("could_not_make_connection", level: .error))
            }, completed: {
                refreshControl.endRefreshing()
            })
        }))
        self.collectionView.refreshControl = refreshControl

        bridge = Bridge.init(collectionView: collectionView, dataSources: dataSources, presenter: presenter, emptyStateViewModel: emptyState)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        os_log("deinit %s", String(describing: self))
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        if self.view.window == nil {
            // Not visible
            for dataSource in self.bridge.dataSources {
                dataSource.fetch(page: 0).start()
            }
        }
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return LifeshareSDK.shared().theme.statusBarStyle
    }

    override open func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)

        self.collectionViewLayout.invalidateLayout()
    }
}
