//
//  MainWindowFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 01/10/2020.
//

import UIKit

struct MainWindowFactory {
    
    func presentWithCollectionAsRoot() -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = PokemonCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        window.makeKeyAndVisible()
        return window
    }
    
    @available(iOS 13.0, *)
    func presentWithCollectionAsRoot(using scene: UIWindowScene) -> UIWindow {
        let window = presentWithCollectionAsRoot()
        window.windowScene = scene
        return window
    }
    
}
