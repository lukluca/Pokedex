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

private extension XCTest {

    func XCTAssertPokemonEqual(_ pokemon1: Pokemon, _ pokemon2: Pokemon, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(pokemon1.name, pokemon2.name, message(), file: file, line: line)
        XCTAssertEqual(pokemon1.id, pokemon2.id, message(), file: file, line: line)
        XCTAssertSpritesEqual(pokemon1.sprites, pokemon2.sprites, message(), file: file, line: line)
    }

    func XCTAssertSpritesEqual(_ sprites1: Sprites, _ sprites2: Sprites, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertDefaultImageEqual(sprites1.frontDefault, sprites2.frontDefault, message(), file: file, line: line)
        XCTAssertImageEqual(sprites1.frontShiny, sprites2.frontShiny, message(), file: file, line: line)
        XCTAssertImageEqual(sprites1.frontFemale, sprites2.frontFemale, message(), file: file, line: line)
        XCTAssertImageEqual(sprites1.frontShinyFemale, sprites2.frontShinyFemale, message(), file: file, line: line)
        XCTAssertImageEqual(sprites1.backDefault, sprites2.backDefault, message(), file: file, line: line)
        XCTAssertImageEqual(sprites1.backShiny, sprites2.backShiny, message(), file: file, line: line)
        XCTAssertImageEqual(sprites1.backFemale, sprites2.backFemale, message(), file: file, line: line)
        XCTAssertImageEqual(sprites1.backShinyFemale, sprites2.backShinyFemale, message(), file: file, line: line)
    }

    func XCTAssertDefaultImageEqual(_ defaultImage1: DefaultImage, _ defaultImage2: DefaultImage, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(defaultImage1.data, defaultImage2.data, message(), file: file, line: line)
    }

    func XCTAssertImageEqual(_ image1: Image?, _ image2: Image?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertEqual(image1?.data, image2?.data, message(), file: file, line: line)
        XCTAssertEqual(image1?.url, image2?.url, message(), file: file, line: line)
    }
}
