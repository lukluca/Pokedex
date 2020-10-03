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

class DBPokemonCatcherTests: XCTestCase {

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    func testIfIsEmptyCallNextHandler() {
        let spy = PokemonCatcherSpy()
        let sut = DBPokemonCatcher(pageSize: 10, nextHandler: spy)

        sut.first { result in }

        XCTAssertEqual(spy.firstInvocations.count, 1)
    }

    func testIfIsNotEmptyDoesNotCallNextHandler() throws {
        try writeInsideDatabase(entities: makeEntities(count:1))

        let spy = PokemonCatcherSpy()
        let sut = DBPokemonCatcher(pageSize: 10, nextHandler: spy)

        sut.first { result in }

        XCTAssertEqual(spy.firstInvocations.count, 0)
    }

    func testRetrievesExpectedPokemonStored() throws {
        let expect = expectation(description: "Completion invocation")
        try writeInsideDatabase(entities: makeEntities(count:1))

        let sut = DBPokemonCatcher(pageSize: 10, nextHandler: DummyPokemonCatcher())

        sut.first { result in
            switch result {
            case .success(let pokemons):
                XCTAssertEqual(pokemons.count, 1)
                XCTAssertEqual(pokemons.first?.id, 0)
                XCTAssertEqual(pokemons.first?.name, "foo_0")
                expect.fulfill()
            case .failure: ()
            }
        }

        wait(for: [expect], timeout: 0)
    }

    func testRetrievesOnlyThePokemonPresentedInsideTheFirstPage() throws {
        let expect = expectation(description: "Completion invocation")
        try writeInsideDatabase(entities: makeEntities(count:100))

        let sut = DBPokemonCatcher(pageSize: 10, nextHandler: DummyPokemonCatcher())

        sut.first { result in
            switch result {
            case .success(let pokemons):
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

    private func writeInsideDatabase(entities: [DBPokemon]) throws {
        let database = try Realm()
        try database.write {
            database.add(entities)
        }
    }

    private func makeEntities(count: Int) -> [DBPokemon] {
        (0 ..< count).compactMap { id -> DBPokemon? in
            guard let path = Bundle(for: DBPokemon.self).path(forResource: nil, ofType: "png") else {
                return nil
            }
            guard let image = UIImage(contentsOfFile: path) else {
                return nil
            }
            let entity = DBPokemon()
            entity.name = "foo_\(id)"
            entity.id = id
            entity.imageData = image.pngData() ?? Data()
            return entity
        }
    }
}
