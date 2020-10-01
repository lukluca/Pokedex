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
    
    private lazy var iOS13 = OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)
    
    @available(iOS 13.0, *)
    func testBackgroundColorForDarkAwareSystems() throws {
        //ifVersionAtLeast 13
        try XCTSkipUnless(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13))
        
        XCTAssertEqual(sut.collectionView.backgroundColor, .systemBackground)
    }
    
    func testBackgroundColorIsWhite() throws {
        //ifVersionBelow 13
        try XCTSkipIf(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13))
        
        XCTAssertEqual(sut.collectionView.backgroundColor, .white)
    }
}
