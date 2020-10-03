//
//  CollectionViewModel.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import UIKit

class CollectionViewModel {

    private var cellViewModels = [CellViewModel]()

    private let catcher: PokemonCatcher

    init(catcher: PokemonCatcher) {
        self.catcher = catcher
    }

    func numberOfItems(in section: Int) -> Int {
        cellViewModels.count
    }

    func item(at indexPath: IndexPath) -> CellViewModel {
        cellViewModels[indexPath.row]
    }

    func getPokemons(completion: @escaping (Result<Void, Error>) -> Void) {
        catcher.firstPage { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let list):
                self.append(list.pokemons.compactMap {self.convert($0)})
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func convert(_ pokemon: Pokemon) -> CellViewModel? {
        guard let image = UIImage(data: pokemon.imageData) else {
            return nil
        }
        return CellViewModel(text: pokemon.name, image: image)
    }

    private func append(_ items: [CellViewModel]) {
        cellViewModels.append(contentsOf: items)
    }


    func getMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
        //or the task for the selected index is ongoing or we have already the data
    }

    func cancelGetMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
    }
}
