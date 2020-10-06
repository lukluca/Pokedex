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
    private let sprites: Sprites

    init(title: String, sprites: Sprites) {
        self.title = title
        self.sprites = sprites
    }

    func numberOfItems(in section: Int) -> Int {
        collection.count
    }

    func item(at indexPath: IndexPath) -> DetailCellViewModel {
        collection[indexPath.item]
    }
}
