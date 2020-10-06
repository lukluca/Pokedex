//
//  DetailCellViewModel.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import Foundation

class DetailViewModel {
    let title: String
    private var collection = [DetailCellViewModel]()

    init(title: String) {
        self.title = title
    }

    func numberOfItems(in section: Int) -> Int {
        collection.count
    }

    func item(at indexPath: IndexPath) -> DetailCellViewModel {
        collection[indexPath.item]
    }
}
