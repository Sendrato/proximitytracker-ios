//
//  CollectionView.swift
//  LifeshareSDK
//
//  Created by Jacco Taal on 19/02/2020.
//

import Foundation
import UIKit

public class CollectionView: UICollectionView {
    let emptyState: EmptyStateView

    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        emptyState = EmptyStateView()

        super.init(frame: frame, collectionViewLayout: layout)

        backgroundView = emptyState
        emptyState.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        emptyState.translatesAutoresizingMaskIntoConstraints = true
        emptyState.setNeedsLayout()

        // Set to Red to indicate that this should be overriden by the caller
        backgroundColor = .red
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        emptyState.setNeedsLayout()
        emptyState.layoutIfNeeded()
    }}

public extension Theme {

    func collectionView(frame: CGRect = .zero, collectionViewLayout: UICollectionViewLayout) -> CollectionView {
        return CollectionView(frame: frame, collectionViewLayout: collectionViewLayout)
            .backgroundColor(backgroundColor)
            .tintColor(tintColor)
    }
}
