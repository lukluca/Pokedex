//
//  PokemonCollectionViewControllerFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import Foundation

struct PokemonCollectionViewControllerFactory {

    func make() -> PokemonCollectionViewController {
        let db = DBFactory().make()
        let saver = DBPokemonSaver(db: db)
        let remote = RemotePokemonCatcher(nextHandler: saver)
        let database = DBPokemonCatcher(db: db, nextHandler: remote)
        let viewModel = CollectionViewModel(pageSize: 50, catcher: database)
        return PokemonCollectionViewController(collectionViewLayout: PokemonCollectionViewFlowLayout(), viewModel: viewModel)
    }
}
