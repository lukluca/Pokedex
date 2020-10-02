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
        
        XCTAssertEqual(sut.collectionView.backgroundColor, .systemBackground)
    }
    
    func testBackgroundColorIsWhite() throws {
        //ifVersionBelow 13
        try XCTSkipIf(ProcessInfo.processInfo.isOperatingSystemAtLeast(iOS13))

        let sut = makeSUT()
        
        XCTAssertEqual(sut.collectionView.backgroundColor, .white)
    }

    func testBindingCellFromCellViewModel() {
        let text = "foo"
        let image = UIImage()
        let viewModel = OneItemCollectionViewModel(text: text, image: image)

        let sut = makeSUT(viewModel: viewModel)

        let cell = sut.collectionView(sut.collectionView, cellForItemAt: IndexPath(item: 0, section: 0)) as? PokemonCollectionViewCell

        XCTAssertNotNil(cell, "The cell must be a PokemonCollectionViewCell")

        let sameImageInstance = cell?.image === image

        XCTAssertEqual(cell?.name, text)
        XCTAssertTrue(sameImageInstance)
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
