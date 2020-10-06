//
//  ViewModelsConverterTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import XCTest
import RealmSwift
@testable import Pokedex

class ViewModelsConverterTests {

    func testConvertsPokemonIntoCellViewModel() {
        let sut = ViewModelsConverter()

        let id = 5
        let name = "foo"
        let data = makeRandomData()

        let cellViewModel = sut.convertIntoCellViewModels([makePokemon(id: id, name: name, frontDefaultData: data)])

        XCTAssertNotNil(cellViewModel.first)
        XCTAssertEqual(cellViewModel.first?.id, id)
        XCTAssertEqual(cellViewModel.first?.image.pngData(), data)
        XCTAssertEqual(cellViewModel.first?.text, name)
    }

    private func makePokemon(id: Int, name: String, frontDefaultData: Data) -> Pokemon {
        PokemonFixture().makePokemon(id: id, name: name, frontDefaultData: frontDefaultData)
    }

    private func makeRandomData() -> Data {
        DataFixture().makeRandomData()
    }
}
