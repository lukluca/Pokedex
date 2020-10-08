//
//  CollectionViewModel.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import UIKit

class CollectionViewModel {

    private let pageSize: Int
    private let catcher: PokemonCatcher

    private var cellViewModels = [CellViewModel]()
    private var pokemons = [Pokemon]()

    private var totalNumberOfItems = 0

    init(pageSize: Int, catcher: PokemonCatcher) {
        self.pageSize = pageSize
        self.catcher = catcher
    }

    func numberOfItems(in section: Int) -> Int {
        totalNumberOfItems
    }

    func item(at indexPath: IndexPath) -> CellViewModel? {
        cellViewModels.first { (model: CellViewModel) -> Bool in
            model.id == indexPath.row
        }
    }

    func pokemon(at index: Int) -> Pokemon? {
        pokemons.first { (pokemon: Pokemon) -> Bool in
            pokemon.id == index
        }
    }

    func getPokemons(completion: @escaping (Result<Void, Error>) -> Void) {
        catcher.firstPage(pageSize: pageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let list):
                self.totalNumberOfItems = list.totalPokemonCount
                self.append(list.pokemons)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func append(_ pokemons: [Pokemon]) {
        self.pokemons.append(contentsOf: pokemons)
        let viewModels = ViewModelsConverter().convertIntoCellViewModels(pokemons)
        append(viewModels)
    }

    private func append(_ items: [CellViewModel]) {
        cellViewModels.append(contentsOf: items)
    }

    func getMorePokemonsIfNeeded(for indexPaths: [IndexPath], completion: @escaping ([IndexPath]) -> Void) {
        let pagesFromIndexPaths = pagesFrom(indexPaths: indexPaths)

        let uniquePageNumbers = Set(pagesFromIndexPaths)

        let pagesWithoutATask = uniquePageNumbers.filter { page -> Bool in
            !catcher.taskOngoing(for: page)
        }

        let indexPathsWithoutAnItem = indexPaths.filter { path -> Bool in
            item(at: path) == nil
        }

        let pagesWithoutAnItem = pagesFrom(indexPaths: indexPathsWithoutAnItem)

        if !pagesWithoutATask.isEmpty && !pagesWithoutAnItem.isEmpty {
            let pages = Array(Set(pagesWithoutATask + pagesWithoutAnItem)).sorted()
            pages.forEach { (pageNumber: Int) in
                getPage(number: pageNumber, completion: completion)
            }
        } else {
            completion([])
        }
    }

    private func getPage(number: Int, completion: @escaping ([IndexPath]) -> Void) {
        catcher.page(pageSize: pageSize, number: number) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let pokemons):
                self.append(pokemons)
                let newIndexes = pokemons.map { pokemon -> IndexPath in
                    IndexPath(item: pokemon.id, section: 0)
                }
                completion(newIndexes)
            case .failure:
                completion([])
            }
        }
    }

    private func pagesFrom(indexPaths: [IndexPath]) -> [Int] {
        indexPaths.map { pageNumber(for: $0.item) }
    }

    private func pageNumber(for item: Int) -> Int {
        Int(floor(Double(item) / Double(pageSize)))
    }

    func cancelGetMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
        Set(pagesFrom(indexPaths: indexPaths)).forEach { (page: Int) -> () in
            catcher.stopTask(for: page)
        }
    }
}
