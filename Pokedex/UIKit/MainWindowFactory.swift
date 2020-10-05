//
//  MainWindowFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 01/10/2020.
//

import UIKit
import RealmSwift

struct MainWindowFactory {
    
    func presentWithCollectionEmbeddedInNavigation() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)

        //Move to factory
        let dbUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("pokedex.realm")
        let realm = try? Realm(fileURL: dbUrl!)
        let saver = DBPokemonSaver(db: realm)
        let remote = RemotePokemonCatcher(nextHandler: saver)
        let database = DBPokemonCatcher(db: realm, nextHandler: remote)
        let viewModel = CollectionViewModel(pageSize: 50, catcher: database)
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
