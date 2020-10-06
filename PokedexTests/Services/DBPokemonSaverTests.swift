//
//  DBPokemonSaverTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import XCTest
import RealmSwift
@testable import Pokedex

class DBPokemonSaverTests: RealmTestCase {

    func testSavesTotalPokemonCount() throws {
        let sut = makeSUT()

        let count = 2030
        sut.save(totalPokemonCount: count)

        let pokedex = try readPokedex()

        XCTAssertNotNil(pokedex)
        XCTAssertEqual(pokedex?.totalPokemonCount, count)
    }

    func testSavesPokemons() throws {
        let sut = makeSUT()

        //Todo move inside fixture
        let img = DefaultImage(data: Data())
        let sprites = Sprites(frontDefault: img, frontShiny: nil, frontFemale: nil, frontShinyFemale: nil, backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil)
        let pokemon = Pokemon(id: 10, name: "foo", sprites: sprites)

        sut.save(pokemons: [pokemon])

        let entities = try readPokemons()

        XCTAssertNotNil(entities)
        XCTAssertEqual(entities?.count, 1)
        XCTAssertEqual(entities?.first?.id, 10)
        XCTAssertEqual(entities?.first?.name, "foo")
        XCTAssertEqual(entities?.first?.sprites.frontDefault.data, Data())
    }

    //MARK: Helpers

    private func makeSUT() -> DBPokemonSaver {
        DBPokemonSaver(db: try? makeDatabase())
    }

    private func readPokedex() throws -> DBPokedex? {
        try readFromDatabase(DBPokedex.self)
    }

    private func readPokemons() throws -> Results<DBPokemon>? {
        try readFromDatabase(DBPokemon.self)
    }

    private func readFromDatabase<Element: Object>(_ type: Element.Type) throws -> Element? {
        try makeDatabase().objects(type.self).first
    }

    private func readFromDatabase<Element: Object>(_ type: Element.Type) throws -> Results<Element>? {
        try makeDatabase().objects(type.self)
    }
}
