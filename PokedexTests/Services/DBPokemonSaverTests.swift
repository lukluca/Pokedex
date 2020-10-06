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

        let id = 10
        let name = "foo"
        let data = DataFixture().makeRandomData()
        let pokemon = PokemonFixture().makePokemon(id: id, name: name, frontDefaultData: data)

        sut.save(pokemons: [pokemon])

        let entities = try readPokemons()

        XCTAssertNotNil(entities)
        XCTAssertEqual(entities?.count, 1)
        XCTAssertEqual(entities?.first?.id, id)
        XCTAssertEqual(entities?.first?.name, name)
        XCTAssertEqual(entities?.first?.sprites.frontDefault.data, data)
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
