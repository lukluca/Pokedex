//
//  DBPokemonCatcherTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 03/10/2020.
//
//

import XCTest
import RealmSwift
@testable import Pokedex

class DBPokemonCatcherTests: RealmTestCase {

    func testIfThereAreNoPokemonsCallsNextHandler() {
        let spy = PokemonCatcherSpy()
        let sut = makeSUT(nextHandler: spy)

        sut.firstPage(pageSize: 10) { result in }

        XCTAssertEqual(spy.firstPageInvocations.count, 1)
    }

    func testIfThereArePokemonsDoesNotCallNextHandler() throws {
        try writeInsideDatabase(pokemon: makeAnEntity())
        try writeInsideDatabase(pokedex: makePokedex(with: 1))

        let spy = PokemonCatcherSpy()
        let sut = makeSUT(nextHandler: spy)

        sut.firstPage(pageSize: 10) { result in }

        XCTAssertEqual(spy.firstPageInvocations.count, 0)
    }

    func testRetrievesExpectedPokemonStored() throws {
        let expect = expectation(description: "Completion invocation")
        let data = makeRandomData()
        try writeInsideDatabase(pokemon: makeAnEntity(with: 0, withSpriteFrontDefaultData: data))
        try writeInsideDatabase(pokedex: makePokedex(with: 1))

        let sut = makeSUT()

        sut.firstPage(pageSize: 10) { result in
            switch result {
            case .success(let list):
                XCTAssertEqual(list.totalPokemonCount, 1)
                let pokemons = list.pokemons
                XCTAssertEqual(pokemons.count, 1)
                XCTAssertEqual(pokemons.first?.id, 0)
                XCTAssertEqual(pokemons.first?.name, "foo_0")
                XCTAssertEqual(pokemons.first?.sprites.frontDefault.data, data)
                expect.fulfill()
            case .failure: ()
            }
        }

        wait(for: [expect], timeout: 0)
    }

    func testRetrievesOnlyThePokemonPresentedInsideTheFirstPage() throws {
        let expect = expectation(description: "Completion invocation")
        try writeInsideDatabase(pokemons: makeEntities(count: 100))
        try writeInsideDatabase(pokedex: makePokedex(with: 3050))

        let sut = makeSUT()

        sut.firstPage(pageSize: 10) { result in
            switch result {
            case .success(let list):
                XCTAssertEqual(list.totalPokemonCount, 3050)
                let pokemons = list.pokemons
                XCTAssertEqual(pokemons.count, 10)
                let sorted = pokemons.sorted { (pokemon: Pokemon, pokemon2: Pokemon) -> Bool in
                    pokemon.id < pokemon2.id
                }
                XCTAssertEqual(sorted.first?.id, 0)
                XCTAssertEqual(sorted.first?.name, "foo_0")
                XCTAssertEqual(sorted.last?.id, 9)
                XCTAssertEqual(sorted.last?.name, "foo_9")
                expect.fulfill()
            case .failure: ()
            }
        }

        wait(for: [expect], timeout: 0)
    }

    func testIfThereAreNoPokemonsAtAllWhileReadingAPageCompletesWhitError() {
        let expect = expectation(description: "Completion invocation")
        let sut = makeSUT()

        sut.page(pageSize: 50, number: 2) { result in
            switch result {
            case .success: ()
            case .failure:
                expect.fulfill()
            }
        }

        wait(for: [expect], timeout: 0)
    }

    func testIfThePageIsNotStoredCallsNextHandler() throws {
        let pageSize = 50
        try writeInsideDatabase(pokemons: makeEntities(count: pageSize))

        let spy = PokemonCatcherSpy()
        let sut = makeSUT(nextHandler: spy)

        sut.page(pageSize: pageSize, number: 1) { result in }

        XCTAssertEqual(spy.pageInvocations.count, 1)
    }

    func testIfThePageIsStoredCompletesWhitPokemonsInsideThePage() throws {
        let pageSize = 50
        try writeInsideDatabase(pokemons: makeEntities(count: 3 * pageSize))
        let expect = expectation(description: "Completion invocation")
        let sut = makeSUT()

        sut.page(pageSize: pageSize, number: 1) { result in
            switch result {
            case .success(let pokemons):
                XCTAssertEqual(pokemons.count, 50)
                let sorted = pokemons.sorted { (pokemon: Pokemon, pokemon2: Pokemon) -> Bool in
                    pokemon.id < pokemon2.id
                }
                XCTAssertEqual(sorted.first?.id, 50)
                XCTAssertEqual(sorted.first?.name, "foo_50")
                XCTAssertEqual(sorted.last?.id, 99)
                XCTAssertEqual(sorted.last?.name, "foo_99")
                expect.fulfill()
            case .failure: ()
            }
        }

        wait(for: [expect], timeout: 0)
    }

    //MARK: Helpers

    private func makeSUT(nextHandler: PokemonCatcher = DummyPokemonCatcher()) -> DBPokemonCatcher {
        DBPokemonCatcher(db: try? makeDatabase(), nextHandler: nextHandler)
    }

    private func writeInsideDatabase(pokemon: DBPokemon) throws {
        try writeInsideDatabase(pokemons: [pokemon])
    }

    private func writeInsideDatabase(pokemons: [DBPokemon]) throws {
        try writeInsideDatabase(objects: pokemons)
    }

    private func writeInsideDatabase(pokedex: DBPokedex) throws {
        try writeInsideDatabase(objects: [pokedex])
    }

    private func writeInsideDatabase(objects: [Object]) throws {
        let database = try makeDatabase()
        try database.write {
            database.add(objects)
        }
    }

    private func makePokedex(with total: Int) throws -> DBPokedex {
        let pokedex = DBPokedex()
        pokedex.totalPokemonCount = total
        return pokedex
    }

    private func makeEntities(count: Int) -> [DBPokemon] {
        (0 ..< count).compactMap { id -> DBPokemon? in
            let data = makeRandomData()
            return makeAnEntity(with: id, withSpriteFrontDefaultData: data)
        }
    }

    private func makeAnEntity(with id: Int = 0) -> DBPokemon {
        let entity = DBPokemon()
        entity.name = "foo_\(id)"
        entity.id = id
        entity.sprites.frontDefault.data = makeRandomData()
        return entity
    }

    private func makeAnEntity(with id: Int, withSpriteFrontDefaultData data: Data) -> DBPokemon {
        let entity = DBPokemon()
        entity.name = "foo_\(id)"
        entity.id = id
        entity.sprites.frontDefault.data = data
        return entity
    }

    private func makeRandomData() -> Data {
        DataFixture().makeRandomData()
    }
}
