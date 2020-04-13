//
//  ExploreViewModel.swift
//  LifeshareApps
//
//  Created by Jacco Taal on 16/09/2019.
//  Copyright © 2019 Vidacle B.V. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import ReactiveObjCBridge

@objc(LSExploreViewModel)
open class ExploreViewModel: NSObject, ViewModel {

    let layout: MutableProperty<LayoutList?>
    var path: String

    @objc
    public init(path: String = "layouts/home") {
        self.layout = MutableProperty(nil)
        self.path = path

        super.init()
    }

    enum ExploreViewModelError: Error {
        case invalidLayout
    }

    open func reload() -> SignalProducer<LayoutList, Error> {
        #warning("Is cache buster necessary?")
        return LSApiClient.sharedInstance().get(path: self.path, parameters: ["buster": NSUUID().uuidString])
            .flatMapError({ _ -> SignalProducer<LayoutList, Error> in
                if let fallback = try? self.fallbackLayout() {
                    return SignalProducer(value: fallback)
                }
                return SignalProducer(error: ExploreViewModelError.invalidLayout)
            })
    }

    private func fallbackLayout() throws -> LayoutList  {
        if let url = Bundle.main.url(forResource: "Explore", withExtension: "json") {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(LayoutList.self, from: data)
        }
        return LayoutList(items: [])
    }

    public lazy var reloadItems: RACCommand<AnyObject, AnyObject> = {
        let action = Action<AnyObject?, AnyObject?, Error>(execute: { _ in
            return self.reload()
                .on(value: { value in
                    self.layout.value = value
                })
                .map({ _ in return nil })
        })

        return action.bridged
    }()

}

extension ExploreViewModel: LSStackedViewControllerDataSource {

    public func stackedViewController(_ viewController: LSStackedViewController, itemAt idx: Int) -> LSStackedViewControllerItem {
        let layout = self.layout.value!
        let item = layout.items[idx]

        if let item = item as? StackedViewItemConvertible {
            return item.stackedViewItem(for: viewController)
        }
        let stackItem = LSStackedViewControllerItem()
        return stackItem
    }

    public func numberOfItems(for viewController: LSStackedViewController) -> Int {
        guard let layout = self.layout.value else {
            return 0
        }
        return layout.items.count
    }
}

public class StackItemLayout: Layout, StackedViewItemConvertible {
    public var title: String? {
        return stackItem.title ?? ""
    }

    public var needsAuthentication: Bool = false

    let stackItem: LSStackedViewControllerItem

    public func stackedViewItem(for stackedViewController: LSStackedViewController) -> LSStackedViewControllerItem {
        return stackItem
    }

    public init(stackItem: LSStackedViewControllerItem) {
        self.stackItem = stackItem
    }

    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

public protocol StackedViewItemConvertible {
    func stackedViewItem(for stackedViewController: LSStackedViewController) -> LSStackedViewControllerItem
}

extension AdLayout: StackedViewItemConvertible {
    public func stackedViewItem(for stackedViewController: LSStackedViewController) -> LSStackedViewControllerItem {
        return LSStackedViewControllerItem(view: AdManager.shared.adView(for: self.adContext, presentingViewController: stackedViewController))
    }
}
//
//extension DataSourceLayout: StackedViewItemConvertible {
//    func stackedViewItem(for stackedViewController: LSStackedViewController) -> LSStackedViewControllerItem {
//
//        let vc: UICollectionViewController
//        switch self.dataSource {
//        case is LSStoriesDataSource:
//            let mini = LSMiniStoryCollectionViewController()
//            mini.noDataBackgroundView = nil
//            mini.dataSources = [self.dataSource]
//            vc = mini
//        case is LSDataSource<LSUserModel>:
//            let mini = LSUserAvatarCollectionViewController()
//            mini.noDataBackgroundView = nil
//            mini.dataSources = [self.dataSource]
//            if let flowLayout = mini.collectionViewLayout as? UICollectionViewFlowLayout {
//                flowLayout.scrollDirection = .horizontal
//            }
//            vc = mini
//        default:
//            fatalError("Unknown datasource")
//        }
//
//        vc.collectionView.alwaysBounceVertical = false
//        vc.collectionView.isDirectionalLockEnabled = true
//        vc.collectionView.backgroundColor = .clear
//        vc.view.backgroundColor = .clear
//        vc.collectionView.contentInset = UIEdgeInsets(top:2, left: 4, bottom: 6, right: 4)
//        vc.collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 2, left: 8, bottom: 0, right:8 )
//
//        let item = LSStackedViewControllerItem(view: vc.view, title: title)
//        item.viewController = vc
//        if let flow = vc.collectionViewLayout as? UICollectionViewFlowLayout {
//            NSLayoutConstraint.activate([vc.view.heightAnchor.constraint(equalToConstant: flow.itemSize.height + 8.0)])
//        }
//
//        return item;
//    }
//}

extension PlaylistLayout: StackedViewItemConvertible {
    public func stackedViewItem(for stackedViewController: LSStackedViewController) -> LSStackedViewControllerItem {

        let playerView = LSPlayerView(frame: .zero)
        let playerViewContainer = LSPlayerViewContainer(playerView: playerView)
        playerViewContainer.translatesAutoresizingMaskIntoConstraints = false

        PlaylistPlayerDataSource.load(playlist: self.playlist)
            .start { event in
                switch event {
                case .value(let dataSource):
                    let viewModel = PlayerViewModel(dataSource: dataSource)
                    // this is disabled for now, as the Ad System does not support multiple simultaneous ads
                    //playerView.adPlayerSession = viewModel.adPlayerSession

                    playerView.overlayDataSource = dataSource
                    playerView.avplayer = viewModel.player
                    playerView.viewModel = viewModel // retain
                    playerView.titleLabel?.text = dataSource.title
                    playerView.titleLabelSecondary?.text = nil
                default:
                    ()
                }
            }

        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.titleLabelSecondary?.text = nil
        playerView.layer.cornerRadius = LifeshareSDK.shared().theme.decorativeCornerRadius
        playerView.layer.masksToBounds = true
        playerView.delegate = stackedViewController

        let padding = UIView()
        padding.addSubview(playerViewContainer)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerViewContainer.embed(inView: padding, margin: 16.0)

        let item = LSStackedViewControllerItem(view: padding)
        item.header = nil

        playerViewContainer.widthAnchor.constraint(equalTo: playerViewContainer.heightAnchor, multiplier: 16.0 / 9.0).isActive = true
        return item
    }
}
