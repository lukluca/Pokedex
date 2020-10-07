//
//  DetailViewControllerFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 7/10/2020.
//

import Foundation

struct DetailViewControllerFactory {

    func make(id: Int, title: String, sprites: Sprites) -> DetailViewController {
        let downloader = RemoteDataDownloader(session: URLSession.shared)
        let db = DBFactory().make()
        let updater = DBPokemonUpdater(db: db, id: id)
        let loader = SpritesDownloader(dataDownloader: downloader, nextHandler: updater)
        let viewModel = DetailViewModel(title: title, sprites: sprites, loader: loader)
        return DetailViewController(viewModel: viewModel)
    }

}
