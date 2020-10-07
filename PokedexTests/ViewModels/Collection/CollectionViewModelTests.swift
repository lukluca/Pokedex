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

    func testOnInitGetsNilPokemon() {
        let sut = makeSUT()

        XCTAssertNil(sut.pokemon(at: 0), "Too much pokemon!")
    }

    func testOnInitGetsNilItem() {
        let sut = makeSUT()

        XCTAssertNil(sut.item(at: IndexPath(item: 0, section: 0)))
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
        let pokemon = makeAPokemon(withId: 0, name: "foo", imageData: imageData)
        let list = makeAPokemonList(withTotalPokemonCount: 100, andOnlyOnePokemon: pokemon)
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in
            switch result {
            case .success:
                XCTAssertEqual(sut.numberOfItems(in: 0), 100, "numberOfItems must be equal to totalPokemonCount")
                let item = sut.item(at: IndexPath(item: 0, section: 0))
                XCTAssertNotNil(item, "Item must be not nil if pokemon is present inside data source")
                XCTAssertEqual(item?.text, "Foo", "Failure while converting pokemon")
                XCTAssertImageEqualToData(item?.image, imageData, "Failure while converting pokemon")
                let nilItem = sut.item(at: IndexPath(item: 1, section: 0))
                XCTAssertNil(nilItem, "Item must be nil if pokemon is no present inside data source")
                expectation.fulfill()
            case .failure:()
            }
        }

        mock.simulateFirstPageOnSuccess()

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

        mock.simulateFirstPageOnFailure()

        wait(for: [expectation], timeout: 0)
    }

    func testGetsNilItemWhenQueryingAnHoleInsideDataSource() throws {
        let list = try makeAPokemonList(withTotalPokemonCount: 10, andOnlyOnePokemonWithId: 8)
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in }

        mock.simulateFirstPageOnSuccess()

        let item = sut.item(at: IndexPath(item: 5, section: 0))

        XCTAssertNil(item, "Item must be nil")
    }

    func testDoesntGetsMorePokemonIfThereIsATaskOngoingForTheIndex() {
        let index = 3
        let mock = PokemonCatcherMock(taskOngoingForIndex: index)
        let sut = makeSUT(catcher: mock)

        sut.getMorePokemonsIfNeeded(for: [IndexPath(item: index, section: 0)]) { result in }
        XCTAssertEqual(mock.taskOngoingForInvocations.count, 1, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.taskOngoingForInvocations.first, index, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.pageInvocations.count, 0, "If the task is ongoing for the index, you don't have to load the page")
    }

    func testDoesntGetsMorePokemonIfTheDataIsAlreadyCatched() throws {
        let expectation = XCTestExpectation(description: "Completion invoked")
        let id = 8
        let list = try makeAPokemonList(withTotalPokemonCount: 10, andOnlyOnePokemonWithId: id)
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(pageSize: 10, catcher: mock)

        sut.getPokemons { result in  }
        mock.simulateFirstPageOnSuccess()

        sut.getMorePokemonsIfNeeded(for: [IndexPath(item: id, section: 0)]) { newItems in
            XCTAssertTrue(newItems.isEmpty)
            expectation.fulfill()
        }

        XCTAssertEqual(mock.taskOngoingForInvocations.count, 1, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.taskOngoingForInvocations.first, 0, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.pageInvocations.count, 0, "If the task is ongoing for the index, you don't have to load the page")

        wait(for: [expectation], timeout: 0)
    }

    func testGetsMorePokemonIfTheDataIsNotAlreadyCatched() throws {
        let pageSize = 50
        let list = try makeAPokemonList(withTotalPokemonCount: 10, andOnlyOnePokemonWithId: 9)
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(pageSize: pageSize, catcher: mock)

        sut.getPokemons { result in  }
        mock.simulateFirstPageOnSuccess()

        sut.getMorePokemonsIfNeeded(for: [IndexPath(item: 57, section: 0)]) { _ in}

        XCTAssertEqual(mock.taskOngoingForInvocations.count, 1, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.taskOngoingForInvocations.first, 1, "Missing ask the catcher if there is a task ongoing")
        XCTAssertEqual(mock.pageInvocations.count, 1, "Missing load of the required page")
        XCTAssertEqual(mock.pageInvocations.first?.number, 1, "Missing load of the required page")
        XCTAssertEqual(mock.pageInvocations.first?.pageSize, pageSize, "Missing load of the required page")
    }

    func testGetsMorePokemonCompletingWithSuccess() throws {
        let expectation = XCTestExpectation(description: "Completion invoked")
        let list = try makeAPokemonList(withTotalPokemonCount: 10, andOnlyOnePokemonWithId: 20)
        let pokemon = try makeAPokemon(withId: 12)
        let mock = PokemonCatcherMock(pokemonList: list, pokemons: [pokemon])
        let sut = makeSUT(pageSize: 50, catcher: mock)

        sut.getPokemons { result in  }
        mock.simulateFirstPageOnSuccess()

        sut.getMorePokemonsIfNeeded(for: [IndexPath(item: 7, section: 0)]) { newItems in
            XCTAssertEqual(newItems.count, 1)
            XCTAssertEqual(newItems.first, IndexPath(item: 12, section: 0))
            XCTAssertNotNil(sut.item(at: IndexPath(item: 12, section: 0)), "Missing append new cell view models")
            expectation.fulfill()
        }

        mock.simulateNextPageOnSuccess()

        wait(for: [expectation], timeout: 0)
    }

    func testGetsMorePokemonCompletingWithFailure() throws {
        let expectation = XCTestExpectation(description: "Completion invoked")
        let list = try makeAPokemonList(withTotalPokemonCount: 10, andOnlyOnePokemonWithId: 20)
        let mock = PokemonCatcherMock(pokemonList: list, error: dummyError)
        let sut = makeSUT(pageSize: 50, catcher: mock)

        sut.getPokemons { result in  }
        mock.simulateFirstPageOnSuccess()

        sut.getMorePokemonsIfNeeded(for: [IndexPath(item: 7, section: 0)]) { newItems in
            XCTAssertTrue(newItems.isEmpty)
            expectation.fulfill()
        }

        mock.simulateNextPageOnFailure()

        wait(for: [expectation], timeout: 0)
    }

    func testGetsNilPokemon() throws {
        let list = try makeAPokemonList(withTotalPokemonCount: 10, andOnlyOnePokemonWithId: 8)
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in }

        mock.simulateFirstPageOnSuccess()

        XCTAssertNil(sut.pokemon(at: 7), "Too much pokemon!")
    }

    func testGetsPokemon() throws {
        let expectedPokemon = try makeAPokemon(withId: 8)
        let list = makeAPokemonList(withTotalPokemonCount: 10, andOnlyOnePokemon: expectedPokemon)
        let mock = PokemonCatcherMock(pokemonList: list)
        let sut = makeSUT(catcher: mock)

        sut.getPokemons { result in }

        mock.simulateFirstPageOnSuccess()

        let pokemon = sut.pokemon(at: 8)

        XCTAssertPokemonEqual(pokemon, expectedPokemon)
    }

    //MARK: Helpers

    private func makeSUT(pageSize: Int = 1, catcher: PokemonCatcher = DummyPokemonCatcher()) -> CollectionViewModel {
        CollectionViewModel(pageSize: pageSize, catcher: catcher)
    }

    private func makeAPokemonList(withTotalPokemonCount count: Int, andOnlyOnePokemonWithId id: Int) throws -> PokemonList {
        let pokemon = try makeAPokemon(withId: id)
        return makeAPokemonList(withTotalPokemonCount: count, andOnlyOnePokemon: pokemon)
    }

    private func makeAPokemonList(withTotalPokemonCount count: Int, andOnlyOnePokemon pokemon: Pokemon) -> PokemonList {
        PokemonList(totalPokemonCount: count, pokemons: [pokemon])
    }

    private func makeAPokemon(withId id: Int, name: String = "") throws -> Pokemon {
        let imageData = try UIImage.imageResourceAsData(insideBundleOf: CollectionViewModel.self)
        return makeAPokemon(withId: id, name: name, imageData: imageData)
    }

    private func makeAPokemon(withId id: Int, name: String = "", imageData: Data) -> Pokemon {
        PokemonFixture().makePokemon(id: id, name: name, frontDefaultData: imageData)
    }
}

private class PokemonCatcherMock: PokemonCatcherSpy {

    let pokemonList: PokemonList?
    let error: Error?
    let taskOngoingForIndex: Int?
    let pokemons: [Pokemon]?

    init(pokemonList: PokemonList){
        self.pokemonList = pokemonList
        self.error = nil
        self.taskOngoingForIndex = nil
        self.pokemons = nil
    }

    init(error: Error) {
        self.pokemonList = nil
        self.error = error
        self.taskOngoingForIndex = nil
        self.pokemons = nil
    }

    init(taskOngoingForIndex: Int) {
        self.pokemonList = nil
        self.error = nil
        self.taskOngoingForIndex = taskOngoingForIndex
        self.pokemons = nil
    }

    init(pokemonList: PokemonList, pokemons: [Pokemon]) {
        self.pokemonList = pokemonList
        self.error = nil
        self.taskOngoingForIndex = nil
        self.pokemons = pokemons
    }

    init(pokemonList: PokemonList, error: Error) {
        self.pokemonList = pokemonList
        self.error = error
        self.taskOngoingForIndex = nil
        self.pokemons = nil
    }

    override func taskOngoingFor(for index: Int) -> Bool {
        let _ = super.taskOngoingFor(for: index)
        return taskOngoingForIndex == index
    }

    func simulateFirstPageOnSuccess() {
        guard let list = pokemonList else {
            return
        }
        firstPageInvocations.first?.completion(Result.success(list))
    }

    func simulateFirstPageOnFailure() {
        guard let error = error else {
            return
        }
        firstPageInvocations.first?.completion(Result.failure(error))
    }

    func simulateNextPageOnSuccess() {
        guard let pokemons = pokemons else {
            return
        }
        pageInvocations.first?.completion(Result.success(pokemons))
    }

    func simulateNextPageOnFailure() {
        guard let error = error else {
            return
        }
        pageInvocations.first?.completion(Result.failure(error))
    }
}

//MARK: XCTAssert Pokemon and equalities

private func XCTAssertPokemonEqual(_ pokemon1: Pokemon?, _ pokemon2: Pokemon?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(pokemon1?.name, pokemon2?.name, message(), file: file, line: line)
    XCTAssertEqual(pokemon1?.id, pokemon2?.id, message(), file: file, line: line)
    XCTAssertSpritesEqual(pokemon1?.sprites, pokemon2?.sprites, message(), file: file, line: line)
}

private func XCTAssertSpritesEqual(_ sprites1: Sprites?, _ sprites2: Sprites?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertDefaultImageEqual(sprites1?.frontDefault, sprites2?.frontDefault, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.frontShiny, sprites2?.frontShiny, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.frontFemale, sprites2?.frontFemale, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.frontShinyFemale, sprites2?.frontShinyFemale, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backDefault, sprites2?.backDefault, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backShiny, sprites2?.backShiny, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backFemale, sprites2?.backFemale, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backShinyFemale, sprites2?.backShinyFemale, message(), file: file, line: line)
}

private func XCTAssertDefaultImageEqual(_ defaultImage1: DefaultImage?, _ defaultImage2: DefaultImage?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(defaultImage1?.data, defaultImage2?.data, message(), file: file, line: line)
}

private  func XCTAssertImageEqual(_ image1: Image?, _ image2: Image?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(image1?.data, image2?.data, message(), file: file, line: line)
    XCTAssertEqual(image1?.url, image2?.url, message(), file: file, line: line)
}
