//
//  PokemonCollectionViewFlowLayout.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 1/10/2020.
//

import UIKit

class PokemonCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()

        let spacing: CGFloat = 20
        self.minimumInteritemSpacing = spacing
        self.minimumLineSpacing = spacing
        self.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        let cellsPerRow: Int
        switch collectionView.traitCollection.horizontalSizeClass {
        case .regular:
            cellsPerRow = 3
        case .compact:
            cellsPerRow = 2
        case .unspecified:
            cellsPerRow = 2
        @unknown default:
            cellsPerRow = 2
        }
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        itemSize = CGSize(width: itemWidth, height: itemWidth)
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let invalidationContext = super.invalidationContext(forBoundsChange: newBounds)
        guard let context = invalidationContext as? UICollectionViewFlowLayoutInvalidationContext else {
            return invalidationContext
        }
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}