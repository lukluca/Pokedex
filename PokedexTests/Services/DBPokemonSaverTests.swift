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

        let pokemonList = try readPokemonsList()

        XCTAssertNotNil(pokemonList)
        XCTAssertEqual(pokemonList?.pokemons.count, 1)
        XCTAssertEqual(pokemonList?.pokemons.first?.id, 10)
        XCTAssertEqual(pokemonList?.pokemons.first?.name, "foo")
        XCTAssertEqual(pokemonList?.pokemons.first?.imageData, Data())
    }

    //MARK: Helpers

    private func makeSUT() -> DBPokemonSaver {
        DBPokemonSaver()
    }

    private func readPokedex() throws -> DBPokedex? {
        try readFromDatabase(DBPokedex.self)
    }

    private func readPokemonsList() throws -> DBPokemonList? {
        try readFromDatabase(DBPokemonList.self)
    }

    private func readFromDatabase<Element: Object>(_ type: Element.Type) throws -> Element? {
        try makeDatabase().objects(type.self).first
    }

    private func makeList(ofSize size: Int) throws -> DBPokemonList {
        let pokemons = try makeEntities(count:size)
        let list = DBPokemonList()
        list.pokemons = pokemons
        return list
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
