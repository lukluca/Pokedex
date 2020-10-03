//
//  CollectionViewModelTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import XCTest
@testable import Pokedex

class CollectionViewModelTests: XCTestCase {

    func testOnInitDataSourceIsEmpty() {
        let sut = makeSUT()

        XCTAssertEqual(sut.numberOfItems(in: 0), 0)
    }

    func testCatchesFirstPokemonsFromService() {
        let spy = PokemonCatcherSpy()
        let sut = makeSUT(catcher: spy)

        sut.getPokemons { result in }

        XCTAssertEqual(spy.firstInvocations.count, 1)
    }

    func testCatchesFirstPokemonsFromServiceWithSuccess() throws {
        let expectation = XCTestExpectation(description: "Completion invoked")
        let pokemon = Pokemon(id: 0, name: "foo", image: UIImage())
        let mock = PokemonCatcherMock(pokemonList: PokemonList(totalPokemonCount: 1, pokemons: [pokemon]))
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in
            if (try? result.get()) != nil {
                expectation.fulfill()
            }
        }

        mock.simulateFirstOnSuccess()

        XCTAssertEqual(sut.numberOfItems(in: 0), 1)
        let item = sut.item(at: IndexPath(item: 0, section: 0))
        let sameImageInstance = item.image === pokemon.image
        XCTAssertEqual(item.text, pokemon.name, "Failure while converting pokemon")
        XCTAssertTrue(sameImageInstance, "Failure while converting pokemon")

        wait(for: [expectation], timeout: 0)
    }

    func testCatchesFirstPokemonsFromServiceWithFailure() throws {
        let expectation = XCTestExpectation(description: "Completion invoked")
        let expectedError = dummyError
        let mock = PokemonCatcherMock(error: expectedError)
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in
            switch result {
            case .failure(let error):
                expectation.fulfill()
                XCTAssertEqual(expectedError, error as NSError)
            case .success:()
            }
        }

        mock.simulateFirstOnError()

        wait(for: [expectation], timeout: 0)
    }

    //MARK: Helpers

    private func makeSUT(catcher: PokemonCatcher = DummyPokemonCatcher()) -> CollectionViewModel {
        CollectionViewModel(catcher: catcher)
    }
}

private class PokemonCatcherMock: PokemonCatcherSpy {

    let pokemonList: PokemonList?
    let error: Error?

    init(pokemonList: PokemonList){
        self.pokemonList = pokemonList
        self.error = nil
    }

    init(error: Error) {
        self.pokemonList = nil
        self.error = error
    }

    func simulateFirstOnSuccess() {
        guard let list = pokemonList else {
            return
        }
        firstInvocations.first?(Result.success(list))
    }

    func simulateFirstOnError() {
        guard let error = error else {
            return
        }
        firstInvocations.first?(Result.failure(error))
    }
}
