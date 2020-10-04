//
//  PokemonCollectionViewControllerTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 1/10/2020.
//

import XCTest
@testable import Pokedex

class PokemonCollectionViewControllerTests: XCTestCase  {

    func testRegisterPokemonCell() {
        let sut = makeSUT()
        let cell = sut.collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: firstIndexPath) as? PokemonCollectionViewCell

        XCTAssertNotNil(cell, "The PokemonCell must be registered")
    }

    func testConfiguresCollection() {
        let sut = makeSUT()

        XCTAssertEqual(sut.collectionView.contentInsetAdjustmentBehavior, .always)
        let prefetch = sut.collectionView.prefetchDataSource as? PokemonCollectionViewController
        XCTAssertEqual(prefetch, sut, "Missing set prefetchDataSource delegate")
    }
    
    func testHasPokedexTitle() {
        let sut = makeSUT()

        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, "Pokedex", "The title must be equal to 'Pokedex'")
    }
    
    private lazy var iOS13 = OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)
    
    @available(iOS 13.0, *)
    func testBackgroundColorForDarkAwareSystems() throws {
        //ifVersionAtLeast 13
        try XCTSkipUnless(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13))

        let sut = makeSUT()
        
        XCTAssertEqual(sut.collectionView.backgroundColor, .systemBackground, "We want a systemBackground")
    }
    
    func testBackgroundColorIsWhite() throws {
        //ifVersionBelow 13
        try XCTSkipIf(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13))

        let sut = makeSUT()
        
        XCTAssertEqual(sut.collectionView.backgroundColor, .white, "We want a white background")
    }

    func testBindingCellFromCellViewModel() {
        let text = "foo"
        let image = UIImage()
        let viewModel = OneItemCollectionViewModel(id: 0, text: text, image: image)

        let sut = makeSUT(viewModel: viewModel)

        let cell = sut.collectionView(sut.collectionView, cellForItemAt: firstIndexPath) as? PokemonCollectionViewCell

        XCTAssertNotNil(cell, "The cell must be a PokemonCollectionViewCell")

        let sameImageInstance = cell?.image === image

        XCTAssertEqual(cell?.name, text, "Missing binding with cell")
        XCTAssertTrue(sameImageInstance, "Missing binding with cell")
    }

    func testDoesNotBindCellFromCellViewModelWhenThereIsNoCellViewModelAvailable() {
        let sut = makeSUT(viewModel: FilledCollectionViewModelWithEmptyCells())

        let cell = sut.collectionView(sut.collectionView, cellForItemAt: firstIndexPath) as? PokemonCollectionViewCell

        XCTAssertNotNil(cell, "The cell must be a PokemonCollectionViewCell")
        XCTAssertNil(cell?.name, "Cell must not be binded")
        XCTAssertNil(cell?.image, "Cell must not be binded")
    }

    func testOnViewDidLoadGetsPokemon() {
        let spy = CollectionViewModelSpy()
        let sut = makeSUT(viewModel: spy)

        sut.loadViewIfNeeded()

        XCTAssertEqual(spy.getPokemonsInvocations.count, 1, "On view did load must get Pokemon")
    }

    func testIfThereAreProblemsGettingPokemonsDisplaysAnAlertOnlyIfViewIsAppeared() {
        let stub = CollectionViewModelStub()
        let sut = makeSUT(viewModel: stub)

        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()

        addTeardownBlock {
            window.resignKey()
            window.isHidden = true
        }

        sut.loadViewIfNeeded()

        stub.simulateGetPokemonsFailure()

        let alert = sut.presentedViewController as? UIAlertController

        XCTAssertNil(alert)

        sut.viewDidAppear(true)

        let presentedAlert = sut.presentedViewController as? UIAlertController

        XCTAssertNotNil(presentedAlert)

        let lastTitle = "Retry"
        XCTAssertEqual(presentedAlert?.title, "Failure")
        XCTAssertEqual(presentedAlert?.message, "There was an error getting the Pokemons!")
        XCTAssertEqual(presentedAlert?.actions.count, 2)
        XCTAssertEqual(presentedAlert?.actions.first?.title, "Ok")
        XCTAssertEqual(presentedAlert?.actions.last?.title, lastTitle)

        presentedAlert?.tapButton(title: lastTitle)
        XCTAssertEqual(stub.getPokemonsInvocations.count, 2, "The user wanted to try again!")
    }

    func testGetMorePokemonsWhenPrefetchingItems() {
        let spy = CollectionViewModelSpy()
        let sut = makeSUT(viewModel: spy)

        sut.collectionView(sut.collectionView, prefetchItemsAt: indexPaths)

        XCTAssertEqual(spy.getMorePokemonsIfNeededInvocations.count, 1, "The collection need more Pokemon!")
        XCTAssertEqual(spy.getMorePokemonsIfNeededInvocations.first, indexPaths)
    }

    func testCancelGetMorePokemonsWhenCancellingPrefetchOfItems() {
        let spy = CollectionViewModelSpy()
        let sut = makeSUT(viewModel: spy)

        sut.collectionView(sut.collectionView, cancelPrefetchingForItemsAt: indexPaths)

        XCTAssertEqual(spy.cancelMorePokemonsIfNeededInvocations.count, 1, "The collection cancelled more Pokemon request!")
        XCTAssertEqual(spy.cancelMorePokemonsIfNeededInvocations.first, indexPaths)
    }

    //MARK: Helpers

    private func makeSUT(viewModel: CollectionViewModel = CollectionViewModel(pageSize: 50, catcher: DummyPokemonCatcher())) -> PokemonCollectionViewController {
        PokemonCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout(), viewModel: viewModel)
    }

    private lazy var firstIndexPath = IndexPath(item: 0, section: 0)

    private lazy var indexPaths = [IndexPath(item: 5, section: 0), IndexPath(item: 10, section: 0), IndexPath(item: 20, section: 0)]
}

private class FilledCollectionViewModelWithEmptyCells: CollectionViewModel {

    init() {
        super.init(pageSize: 50, catcher: DummyPokemonCatcher())
    }

    override func numberOfItems(in section: Int) -> Int {
        10
    }

    override func item(at indexPath: IndexPath) -> CellViewModel? {
        nil
    }
}

private class OneItemCollectionViewModel: CollectionViewModel {

    private let id: Int
    private let text: String
    private let image: UIImage

    init(id: Int, text: String, image: UIImage) {
        self.id = id
        self.text = text
        self.image = image
        super.init(pageSize: 50, catcher: DummyPokemonCatcher())
    }

    override func numberOfItems(in section: Int) -> Int {
        1
    }

    override func item(at indexPath: IndexPath) -> CellViewModel? {
        CellViewModel(id: id, text: text, image: image)
    }
}

private class CollectionViewModelSpy: CollectionViewModel {

    private(set) var getPokemonsInvocations = [(Result<(), Error>) -> ()]()
    private(set) var getMorePokemonsIfNeededInvocations = [[IndexPath]]()
    private(set) var cancelMorePokemonsIfNeededInvocations = [[IndexPath]]()

    init() {
        super.init(pageSize: 50, catcher: DummyPokemonCatcher())
    }

    override func getPokemons(completion: @escaping (Result<(), Error>) -> ()) {
        getPokemonsInvocations.append(completion)
    }

    override func getMorePokemonsIfNeeded(for indexPaths: [IndexPath], completion: @escaping ([IndexPath]) -> Void) {
        getMorePokemonsIfNeededInvocations.append(indexPaths)
    }

    override func cancelGetMorePokemonsIfNeeded(at indexPaths: [IndexPath]) {
        cancelMorePokemonsIfNeededInvocations.append(indexPaths)
    }
}

private class CollectionViewModelStub: CollectionViewModelSpy {
    func simulateGetPokemonsFailure() {
        getPokemonsInvocations.first?(Result.failure(NSError.dummyError))
    }
}
