//
//  PokemonCollectionViewController.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 30/09/2020.
//

import UIKit

class PokemonCollectionViewController: UICollectionViewController {

    private let cellReuseIdentifier = "PokemonCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pokedex"

        collectionView?.contentInsetAdjustmentBehavior = .always
        collectionView?.register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        59
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
        cell.backgroundColor = .orange
        return cell
    }
}

