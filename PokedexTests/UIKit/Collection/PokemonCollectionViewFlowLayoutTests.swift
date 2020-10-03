//
//  PokemonCollectionViewFlowLayoutTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 1/10/2020.
//

import XCTest
@testable import Pokedex

class PokemonCollectionViewFlowLayoutTests: XCTestCase  {

    func testInitWithRequiredProperties() {
        let sut = PokemonCollectionViewFlowLayout()

        XCTAssertEqual(sut.minimumInteritemSpacing, 20, "Missing Layout configuration")
        XCTAssertEqual(sut.minimumLineSpacing, 20, "Missing Layout configuration")
        XCTAssertEqual(sut.sectionInset, UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), "Missing Layout configuration")
    }
}
