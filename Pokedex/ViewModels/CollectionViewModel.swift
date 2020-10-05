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
            convertIntoIndex(id: model.id) == indexPath.row
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

    private func convert(_ pokemon: Pokemon) -> CellViewModel? {
        guard let image = UIImage(data: pokemon.imageData) else {
            return nil
        }
        return CellViewModel(id: pokemon.id, text: pokemon.name.firstUppercase, image: image)
    }

    private func append(_ pokemons: [Pokemon]) {
        append(pokemons.compactMap {self.convert($0)})
    }

    private func append(_ items: [CellViewModel]) {
        cellViewModels.append(contentsOf: items)
    }

    func getMorePokemonsIfNeeded(for indexPaths: [IndexPath], completion: @escaping ([IndexPath]) -> Void) {
        let pagesFromIndexPaths = indexPaths.map { (i: IndexPath) -> Int in
            Int(floor(Double(i.item) / Double(pageSize)))
        }
        let uniquePageNumbers = Array(Set(pagesFromIndexPaths)).sorted()

        let pagesWithoutATask = uniquePageNumbers.filter { page -> Bool in
            !catcher.taskOngoingFor(for: page)
        }

        let indexPathsWithoutAnItem = indexPaths.filter { path -> Bool in
            item(at: path) == nil
        }

        let pagesWithoutAnItem = indexPathsWithoutAnItem.map { (i: IndexPath) -> Int in
            Int(floor(Double(i.item) / Double(pageSize)))
        }

        if !pagesWithoutATask.isEmpty && !pagesWithoutAnItem.isEmpty {
            let pages = Array(Set(pagesWithoutATask + pagesWithoutAnItem)).sorted()
            pages.forEach { (pageNumber: Int) in
                getPage(number: pageNumber, completion: completion)
            }
        } else {
            completion([])
        }
    }

    private func convertIntoIndex(id: Int) -> Int {
        id - 1
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
                    let item = self.convertIntoIndex(id: pokemon.id)
                    return IndexPath(item: item, section: 0)
                }
                completion(newIndexes)
            case .failure:
                completion([])
            }
        }
    }

    func cancelGetMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
    }
}

private extension StringProtocol {
    var firstUppercase: String { prefix(1).uppercased() + dropFirst() }
}
