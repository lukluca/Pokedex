//
//  PokemonCollectionViewController.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 30/09/2020.
//

import UIKit

class PokemonCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        59
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .orange
        return cell
    }
}

