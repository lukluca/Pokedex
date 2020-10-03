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
        let cell = sut.collectionView.dequeueReusableCell(withReuseIdentifier: "PokemonCell", for: IndexPath(item: 0, section: 0)) as? PokemonCollectionViewCell

        XCTAssertNotNil(cell, "The PokemonCell must be registered")
    }

    func testConfiguresCollectionWhitAlwaysContentInsetAdjustmentBehavior() {
        let sut = makeSUT()

        XCTAssertEqual(sut.collectionView.contentInsetAdjustmentBehavior, .always)
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
        let viewModel = OneItemCollectionViewModel(text: text, image: image)

        let sut = makeSUT(viewModel: viewModel)

        let cell = sut.collectionView(sut.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as? PokemonCollectionViewCell

        XCTAssertNotNil(cell, "The cell must be a PokemonCollectionViewCell")

        let sameImageInstance = cell?.image === image

        XCTAssertEqual(cell?.name, text, "Missing binding with cell")
        XCTAssertTrue(sameImageInstance, "Missing binding with cell")
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
        XCTAssertEqual(presentedAlert?.actions.count, 2)
        XCTAssertEqual(presentedAlert?.actions.first?.title, "Ok")
        XCTAssertEqual(presentedAlert?.actions.last?.title, lastTitle)

        presentedAlert?.tapButton(title: lastTitle)
        XCTAssertEqual(stub.getPokemonsInvocations.count, 2, "The user wanted to try again!")
    }

    //MARK: Helper

    private func makeSUT(viewModel: CollectionViewModel = CollectionViewModel()) -> PokemonCollectionViewController {
        PokemonCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout(), viewModel: viewModel)
    }
}

private class OneItemCollectionViewModel: CollectionViewModel {

    private let text: String
    private let image: UIImage

    init(text: String, image: UIImage) {
        self.text = text
        self.image = image
    }

    override func numberOfItems(in section: Int) -> Int {
        1
    }

    override func item(at indexPath: Foundation.IndexPath) -> CellViewModel {
        CellViewModel(text: text, image: image)
    }
}

private class CollectionViewModelSpy: CollectionViewModel {

    private(set) var getPokemonsInvocations = [(Result<(), Error>) -> ()]()

    override func getPokemons(completion: @escaping (Result<(), Error>) -> ()) {
        getPokemonsInvocations.append(completion)
    }
}

private class CollectionViewModelStub: CollectionViewModelSpy {

    func simulateGetPokemonsFailure() {
        getPokemonsInvocations.first?(Result.failure(NSError(domain: "", code: 0, userInfo: nil)))
    }
}
