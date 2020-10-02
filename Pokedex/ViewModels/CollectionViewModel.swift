// See LICENSE.txt for licensing information

import Foundation

class CollectionViewModel {

    private let cellViewModels = [CellViewModel]()

    func numberOfItems(in section: Int) -> Int {
        cellViewModels.count
    }

    func item(at indexPath: IndexPath) -> CellViewModel {
        cellViewModels[indexPath.row]
    }
}
