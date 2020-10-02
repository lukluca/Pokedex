//
//  PokemonCollectionViewController.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 30/09/2020.
//

import UIKit

class PokemonCollectionViewController: UICollectionViewController {

    private let viewModel: CollectionViewModel

    private let cellReuseIdentifier = "PokemonCell"

    init(collectionViewLayout layout: UICollectionViewLayout, viewModel: CollectionViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) unavailable. Use init with layout and view model instead")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Pokedex"
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }

        collectionView.contentInsetAdjustmentBehavior = .always
        collectionView.register(PokemonCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)

        guard let pokemonCell = cell as? PokemonCollectionViewCell else {
            return cell
        }

        let item = viewModel.item(at: indexPath)

        pokemonCell.name = item.text
        pokemonCell.image = item.image

        return pokemonCell
    }
}

