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

    func testMakeMainWindow() throws {
        let window = sut.presentWithCollectionAsRoot()
        let collection = window.rootViewController as? PokemonCollectionViewController
        
        XCTAssertTrue(window.isKeyWindow, "The window must be a key window")
        XCTAssertFalse(window.isHidden, "The window must be visible")
        XCTAssertNotNil(collection, "The root view controller must be a PokemonCollectionViewController")
        XCTAssertNotNil(collection?.collectionViewLayout as? UICollectionViewFlowLayout, "The collectionViewLayout must be a UICollectionViewFlowLayout")
    }
    
    
}
