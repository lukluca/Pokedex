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

        let pokemon = Pokemon(id: 10, name: "foo", imageData: Data())

        sut.save(pokemons: [pokemon])

        let entities = try readPokemons()

        XCTAssertNotNil(entities)
        XCTAssertEqual(entities?.count, 1)
        XCTAssertEqual(entities?.first?.id, 10)
        XCTAssertEqual(entities?.first?.name, "foo")
        XCTAssertEqual(entities?.first?.imageData, Data())
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

    private func makePokedex(with total: Int) throws -> DBPokedex {
        let pokedex = DBPokedex()
        pokedex.totalPokemonCount = total
        return pokedex
    }

    private func makeEntities(count: Int) throws -> List<DBPokemon> {
        let array = try (0 ..< count).compactMap { id -> DBPokemon? in
            let entity = DBPokemon()
            entity.name = "foo_\(id)"
            entity.id = id
            entity.imageData = try UIImage.imageResourceAsData(insideBundleOf: DBPokemon.self)
            return entity
        }

        let list = List<DBPokemon>()
        list.append(objectsIn: array)
        return list
    }
}
