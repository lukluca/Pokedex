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

        XCTAssertEqual(spy.firstPageInvocations.count, 1)
    }

    func testCatchesFirstPokemonsFromServiceWithSuccess() throws {
        let expectation = XCTestExpectation(description: "Completion invoked")
        let imageData = try UIImage.imageResourceAsData(insideBundleOf: CollectionViewModel.self)
        let pokemon = Pokemon(id: 0, name: "foo", imageData: imageData)
        let mock = PokemonCatcherMock(pokemonList: PokemonList(totalPokemonCount: 1, pokemons: [pokemon]))
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in
            switch result {
            case .success:
                XCTAssertEqual(sut.numberOfItems(in: 0), 1)
                let item = sut.item(at: IndexPath(item: 0, section: 0))
                XCTAssertEqual(item.text, pokemon.name, "Failure while converting pokemon")
                XCTAssertEqual(item.image.pngData(), UIImage(data: pokemon.imageData)?.pngData(), "Failure while converting pokemon")
                expectation.fulfill()
            case .failure:()
            }
        }

        mock.simulateFirstOnSuccess()

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
        firstPageInvocations.first?(Result.success(list))
    }

    func simulateFirstOnError() {
        guard let error = error else {
            return
        }
        firstPageInvocations.first?(Result.failure(error))
    }
}
