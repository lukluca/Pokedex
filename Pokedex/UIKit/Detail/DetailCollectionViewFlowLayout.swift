//
//  PokemonCollectionViewFlowLayout.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 1/10/2020.
//

import UIKit

class DetailCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override init() {
        super.init()

        self.minimumInteritemSpacing = 20
        self.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.scrollDirection = .horizontal
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        let marginsAndInsets = sectionInset.top + sectionInset.bottom + collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom
        let itemWidth = ((collectionView.bounds.size.height - marginsAndInsets))
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
