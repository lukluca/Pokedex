//
//  DetailViewControllerFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 7/10/2020.
//

import Foundation

struct DetailViewControllerFactory {

    func make(id: Int, title: String, sprites: Sprites, details: Details) -> DetailViewController {
        let viewModel = DetailViewModelFactory().make(id: id, title: title, sprites: sprites, details: details)
        return DetailViewController(viewModel: viewModel)
    }

}

struct DetailViewModelFactory {

    func make(id: Int, title: String, sprites: Sprites, details: Details) -> DetailViewModel {
        let downloader = RemoteDataDownloader(session: URLSession.shared)
        let db = DBFactory().make()
        let updater = DBPokemonUpdater(db: db, id: id)
        let loader = SpritesDownloader(dataDownloader: downloader, nextHandler: updater)
        return DetailViewModel(number: String((id + 1)),
                title: title,
                baseExperience: String(details.baseExperience),
                height: String(details.height), weight: String(details.weight),
                sprites: sprites,
                loader: loader)
    }
}