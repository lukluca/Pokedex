//
//  DetailViewControllerFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 7/10/2020.
//

import Foundation

struct DetailViewControllerFactory {

    func make(title: String, sprites: Sprites) -> DetailViewController {
        let downloader = RemoteDataDownloader(session: URLSession.shared)
        let viewModel = DetailViewModel(title: title, sprites: sprites, downloader: downloader)
        return DetailViewController(viewModel: viewModel)
    }

}
