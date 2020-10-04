//
//  CollectionViewModel.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import UIKit

class CollectionViewModel {

    private var cellViewModels = [CellViewModel]()

    //rename
    private var numberOfItems = 0

    private let catcher: PokemonCatcher

    init(catcher: PokemonCatcher) {
        self.catcher = catcher
    }

    func numberOfItems(in section: Int) -> Int {
        numberOfItems
    }

    func item(at indexPath: IndexPath) -> CellViewModel? {
        cellViewModels.first { (model: CellViewModel) -> Bool in
            (model.id - 1) == indexPath.row
        }
    }

    func getPokemons(completion: @escaping (Result<Void, Error>) -> Void) {
        catcher.firstPage { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let list):
                self.numberOfItems = list.totalPokemonCount
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
        return CellViewModel(id: pokemon.id, text: pokemon.name, image: image)
    }

    private func append(_ items: [CellViewModel]) {
        cellViewModels.append(contentsOf: items)
    }

    func getMorePokemonsIfNeeded(for indexPaths: [IndexPath], completion: @escaping ([IndexPath]) -> Void) {
        let indexPathsWithoutATask = indexPaths.filter { path -> Bool in
            !catcher.taskOngoingFor(for: path.item)
        }

        let indexPathsWithoutAnItem = indexPaths.filter { path -> Bool in
            item(at: path) == nil
        }

        if !indexPathsWithoutATask.isEmpty && !indexPathsWithoutAnItem.isEmpty {
            let indexes = Array(Set(indexPathsWithoutATask + indexPathsWithoutAnItem)).map { $0.item }.sorted()
            catcher.pageThatContains(indexes: indexes) { result in
                completion([])
            }
        } else {
            completion([])
        }
    }

    func cancelGetMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
    }
}
