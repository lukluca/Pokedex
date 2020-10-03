//
//  PokemonCollectionViewController.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 30/09/2020.
//

import UIKit

class PokemonCollectionViewController: UICollectionViewController {

    private var viewAppeared = false
    private var errorAlert: UIAlertController?

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

        getPokemons()

        collectionView.prefetchDataSource = self
    }

    private func getPokemons() {
        viewModel.getPokemons { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                self.collectionView.reloadData()
            case .failure:
                if self.viewAppeared {
                    self.showErrorAlert()
                } else {
                    self.errorAlert = self.makeErrorAlert()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewAppeared = true

        if let alert = errorAlert {
            present(alert, animated: true)
            errorAlert = nil
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        viewAppeared = false
    }

    private func showErrorAlert() {
        present(makeErrorAlert(), animated: true)
    }

    private func makeErrorAlert() -> UIAlertController {
        let alert = UIAlertController(title: "Failure", message: "There was an error getting the Pokemons!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] action in
            self?.getPokemons()
        }))

        return alert
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)

        guard let pokemonCell = cell as? PokemonCollectionViewCell else {
            return cell
        }

        if let item = viewModel.item(at: indexPath) {
            pokemonCell.name = item.text
            pokemonCell.image = item.image
        } else {
            pokemonCell.name = nil
            pokemonCell.image = nil
        }

        return pokemonCell
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let pokemonCell = cell as? PokemonCollectionViewCell else {
            return
        }

        pokemonCell.startAnimateIfNeeded()
    }

    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let pokemonCell = cell as? PokemonCollectionViewCell else {
            return
        }

        pokemonCell.stopAnimate()
    }
}

extension PokemonCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.getMorePokemonsIfNeeded(at: indexPaths)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        viewModel.cancelGetMorePokemonsIfNeeded(at: indexPaths)
    }
}

