// See LICENSE.txt for licensing information

import Foundation

class CollectionViewModel {

    private let cellViewModels = [CellViewModel]()

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
    }

    func getMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
        //or the task for the selected index is ongoing or we have already the data
    }

    func cancelGetMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
    }
}
