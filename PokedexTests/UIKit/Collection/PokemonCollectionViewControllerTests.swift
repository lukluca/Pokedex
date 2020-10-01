//
//  PokemonCollectionViewControllerTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 1/10/2020.
//

import XCTest
@testable import Pokedex

class PokemonCollectionViewControllerTests: XCTestCase  {
    
    private let sut = PokemonCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())

    func testRegisterPokemonCell() {
        let cell = sut.collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: IndexPath(item: 0, section: 0)) as? PokemonCollectionViewCell

        XCTAssertNotNil(cell, "The PokemonCell must be registered")
    }
    
    func testHasPokedexTitle() {
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "Pokedex", "The title must be equal to 'Pokedex'")
    }
}
