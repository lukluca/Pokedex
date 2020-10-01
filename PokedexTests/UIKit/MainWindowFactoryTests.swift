//
//  PokedexTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 30/09/2020.
//

import XCTest
@testable import Pokedex

class MainWindowFactoryTests: XCTestCase {
    
    private let sut = MainWindowFactory()

    func testPresentsMainWindow() throws {
        let window = sut.presentWithCollectionEmbeddedInNavigation()
        let navigation = window.rootViewController as? UINavigationController
        let navigationViewControllersCount = navigation?.viewControllers.count ?? 0
        let collection = navigation?.viewControllers.first as? PokemonCollectionViewController
        
        XCTAssertTrue(window.isKeyWindow, "The window must be a key window")
        XCTAssertFalse(window.isHidden, "The window must be visible")
        XCTAssertNotNil(navigation, "The root view controller must be a UINavigationController")
        XCTAssertEqual(navigationViewControllersCount, 1, "The navigation must have one controller")
        XCTAssertNotNil(collection, "The navigation root view controller must be a PokemonCollectionViewController")
        XCTAssertNotNil(collection?.collectionViewLayout as? UICollectionViewFlowLayout, "The collectionViewLayout must be a UICollectionViewFlowLayout")
    }
}
