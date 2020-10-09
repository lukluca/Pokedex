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
