//
//  PokemonCollectionViewControllerTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 1/10/2020.
//

import XCTest
@testable import Pokedex

class PokemonCollectionViewControllerTests: XCTestCase  {

    func testRegisterPokemonCell() throws {
        try skipIfVersionBelow(iOS11, "For some reason on iOS 11 the dequeueReusableCell causes a crash of the test suite.")

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

    @available(iOS 13.0, *)
    func testBackgroundColorForDarkAwareSystems() throws {
        try skipIfVersionBelow(iOS13)

        let sut = makeSUT()
        
        XCTAssertEqual(sut.collectionView.backgroundColor, .systemBackground, "We want a systemBackground")
    }
    
    func testBackgroundColorIsWhite() throws {
        try skipIfVersionAtLeast(iOS13)

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

        makeWindowRootController(sut: sut)

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

        XCTAssertEqual(spy.cancelGetMorePokemonsIfNeededInvocations.count, 1, "The collection cancelled more Pokemon request!")
        XCTAssertEqual(spy.cancelGetMorePokemonsIfNeededInvocations.first, indexPaths)
    }

    func testIfUserPressesACellWithoutADataThePressHasNotEffect() {
        let sut = makeSUT(viewModel: FilledCollectionViewModelWithEmptyCells())

        sut.collectionView(sut.collectionView, didSelectItemAt: firstIndexPath)

        XCTAssertNil(sut.presentedViewController)
    }

    func testIfUserPressesACellWithADataTheDetailViewControllerIsPresented() {
        let text = "foo"
        let sut = makeSUT(viewModel: OneItemCollectionViewModel(text: text))

        makeWindowRootController(sut: sut)

        sut.collectionView(sut.collectionView, didSelectItemAt: firstIndexPath)

        let presented = sut.presentedViewController as? DetailViewController
        XCTAssertNotNil(presented)

        let label = presented?.view.subviews.first{ $0 is UILabel } as? UILabel
        XCTAssertEqual(label?.text, text)
    }

    //MARK: Helpers

    private func makeSUT(viewModel: CollectionViewModel = CollectionViewModel(pageSize: 50, catcher: DummyPokemonCatcher())) -> PokemonCollectionViewController {
        PokemonCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout(), viewModel: viewModel)
    }

    private lazy var firstIndexPath = IndexPath(item: 0, section: 0)

    private lazy var indexPaths = [IndexPath(item: 5, section: 0), IndexPath(item: 10, section: 0), IndexPath(item: 20, section: 0)]

    private func makeWindowRootController(sut: PokemonCollectionViewController) {
        let window = UIWindow()
        window.rootViewController = sut
        window.makeKeyAndVisible()

        addTeardownBlock {
            window.resignKey()
            window.isHidden = true
        }
    }
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

    init(id: Int = 0, text: String = "", image: UIImage = UIImage()) {
        self.id = id
        self.text = text
        self.image = image
        super.init(pageSize: 50, catcher: DummyPokemonCatcher())
    }

    override func numberOfItems(in section: Int) -> Int {
        1
    }

    override func pokemon(at index: Int) -> Pokemon? {
        PokemonFixture().makePokemon(id: id, name: text)
    }

    override func item(at indexPath: IndexPath) -> CellViewModel? {
        CellViewModel(id: id, text: text, image: image)
    }
}

private class CollectionViewModelSpy: CollectionViewModel {

    private(set) var getPokemonsInvocations = [(Result<(), Error>) -> ()]()
    private(set) var getMorePokemonsIfNeededInvocations = [[IndexPath]]()
    private(set) var cancelGetMorePokemonsIfNeededInvocations = [[IndexPath]]()

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
        cancelGetMorePokemonsIfNeededInvocations.append(indexPaths)
    }
}

private class CollectionViewModelStub: CollectionViewModelSpy {
    func simulateGetPokemonsFailure() {
        getPokemonsInvocations.first?(Result.failure(NSError.dummyError))
    }
}
