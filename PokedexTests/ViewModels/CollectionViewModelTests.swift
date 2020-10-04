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
        let mock = PokemonCatcherMock(pokemonList: PokemonList(totalPokemonCount: 100, pokemons: [pokemon]))
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in
            switch result {
            case .success:
                XCTAssertEqual(sut.numberOfItems(in: 0), 100, "numberOfItems must be equal to totalPokemonCount")
                let item = sut.item(at: IndexPath(item: 0, section: 0))
                XCTAssertEqual(item?.text, pokemon.name, "Failure while converting pokemon")
                XCTAssertEqual(item?.image.pngData(), UIImage(data: pokemon.imageData)?.pngData(), "Failure while converting pokemon")
                let nilItem = sut.item(at: IndexPath(item: 1, section: 0))
                XCTAssertNil(nilItem, "Item must be nil if pokemon is no present inside data source")
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

    func testGetsNilItemWhenQueryingAnHoleInsideDataSource() throws {
        let imageData = try UIImage.imageResourceAsData(insideBundleOf: CollectionViewModel.self)
        let pokemon = Pokemon(id: 8, name: "foo", imageData: imageData)
        let list = PokemonList(totalPokemonCount: 10, pokemons: [pokemon])
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in }

        mock.simulateFirstOnSuccess()

        let item = sut.item(at: IndexPath(item: 5, section: 0))

        XCTAssertNil(item, "Item must be nil")
    }

    func testDoesntGetsMorePokemonIfThereIsATaskOngoingForTheIndex() {
        let index = 3
        let mock = PokemonCatcherMock(taskOngoingForIndex: index)
        let sut = makeSUT(catcher: mock)

        sut.getMorePokemonsIfNeeded(at: [IndexPath(item: index, section: 0)])
        XCTAssertEqual(mock.taskOngoingForInvocations.count, 1, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.taskOngoingForInvocations.first, index, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.pageThatContainsInvocations.count, 0, "If the task is ongoing for the index, you don't have to load the page")
    }

    func testDoesntGetsMorePokemonIfTheDataIsAlreadyCatch() throws {
        let id = 8
        let imageData = try UIImage.imageResourceAsData(insideBundleOf: CollectionViewModel.self)
        let pokemon = Pokemon(id: id, name: "foo", imageData: imageData)
        let list = PokemonList(totalPokemonCount: 10, pokemons: [pokemon])
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in  }
        mock.simulateFirstOnSuccess()

        sut.getMorePokemonsIfNeeded(at: [IndexPath(item: id, section: 0)])
        XCTAssertEqual(mock.taskOngoingForInvocations.count, 1, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.taskOngoingForInvocations.first, id, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.pageThatContainsInvocations.count, 0, "If the task is ongoing for the index, you don't have to load the page")
    }

    //MARK: Helpers

    private func makeSUT(catcher: PokemonCatcher = DummyPokemonCatcher()) -> CollectionViewModel {
        CollectionViewModel(catcher: catcher)
    }
}

private class PokemonCatcherMock: PokemonCatcherSpy {

    let pokemonList: PokemonList?
    let error: Error?
    let taskOngoingForIndex: Int?

    init(pokemonList: PokemonList){
        self.pokemonList = pokemonList
        self.error = nil
        self.taskOngoingForIndex = nil
    }

    init(error: Error) {
        self.pokemonList = nil
        self.error = error
        self.taskOngoingForIndex = nil
    }

    init(taskOngoingForIndex: Int) {
        self.pokemonList = nil
        self.error = nil
        self.taskOngoingForIndex = taskOngoingForIndex
    }

    override func taskOngoingFor(for index: Int) -> Bool {
        let _ = super.taskOngoingFor(for: index)
        return taskOngoingForIndex == index
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
