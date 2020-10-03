//
//  MainWindowFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 01/10/2020.
//

import UIKit

struct MainWindowFactory {
    
    func presentWithCollectionEmbeddedInNavigation() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let pageSize = 50
        let remote = RemotePokemonCatcher()
        let database = DBPokemonCatcher(pageSize: pageSize, nextHandler: remote)
        let viewModel = CollectionViewModel(catcher: database)
        let collection = PokemonCollectionViewController(collectionViewLayout: PokemonCollectionViewFlowLayout(), viewModel: viewModel)
        window.rootViewController = UINavigationController(rootViewController: collection)
        window.makeKeyAndVisible()
        return window
    }

    @available(iOS 13.0, *)
    func presentWithCollectionEmbeddedInNavigation(using scene: UIWindowScene) -> UIWindow {
        let window = presentWithCollectionEmbeddedInNavigation()
        window.windowScene = scene
        return window
    }

}
