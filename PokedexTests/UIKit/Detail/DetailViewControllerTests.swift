//
//  DetailViewControllerTests.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 06/10/2020.
//
//

import XCTest
@testable import Pokedex

enum DetailViewControllerTestsError: Error {
    case missingRequiredCollection
}

class DetailViewControllerTests: XCTestCase {

    @available(iOS 13.0, *)
    func testBackgroundColorForDarkAwareSystems() throws {
        try skipIfVersionBelow(iOS13)

        let sut = makeSUT()

        XCTAssertEqual(sut.view.backgroundColor, .systemBackground, "We want a systemBackground")
    }

    func testBackgroundColorIsWhite() throws {
        try skipIfVersionAtLeast(iOS13)

        let sut = makeSUT()

        XCTAssertEqual(sut.view.backgroundColor, .white, "We want a white background")
    }

    @available(iOS 13.0, *)
    func testDoesNotHaveACloseButton() throws  {
        try skipIfVersionBelow(iOS13)

        let sut = makeSUT()

        XCTAssertNil(sut.closeButton, "Use swipe down gesture instead")
    }

    func testDoesHaveACloseButton() throws  {
        try skipIfVersionAtLeast(iOS13)

        let sut = makeSUT()

        let closeButton = sut.closeButton

        XCTAssertNotNil(closeButton)

        let image = closeButton?.image(for: .normal)
        XCTAssertNotNil(image, "Missing configure button")
        XCTAssertEqual(image, UIImage(named: "close"), "Missing configure button")

        let target = sut.target(forAction: #selector(DetailViewController.closeAction), withSender: closeButton)
        XCTAssertNotNil(target, "Missing configure button")
    }

    func testDoesHaveATitleLabel() {
        let title = "foo"
        let sut = makeSUT(title: title)

        let titleLabel = sut.titleLabel

        XCTAssertNotNil(titleLabel)
        XCTAssertEqual(titleLabel?.text, title)
        XCTAssertEqual(titleLabel?.textAlignment, .center)
    }

    func testDoesHaveACollectionView() {
        let sut = makeSUT()

        XCTAssertNotNil(sut.collectionView)
    }

    func testRegisterImageCell() {
        let sut = makeSUT()
        let cell = sut.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: firstIndexPath) as? ImageCollectionViewCell

        XCTAssertNotNil(cell, "The ImageCell must be registered")
    }

    func testConfiguresCollection() {
        let sut = makeSUT()

        XCTAssertEqual(sut.collectionView?.contentInsetAdjustmentBehavior, .always)
        let dataSource = sut.collectionView?.dataSource as? DetailViewController
        XCTAssertEqual(dataSource, sut, "Missing set dataSource delegate")
    }

    func testBindingCellFromCellViewModel() throws {
        let image = UIImage()
        let viewModel = OneItemViewModel(image: image)

        let sut = makeSUT(viewModel: viewModel)

        guard let collectionView = sut.collectionView else {
            throw DetailViewControllerTestsError.missingRequiredCollection
        }

        let cell = sut.collectionView(collectionView, cellForItemAt: firstIndexPath) as? ImageCollectionViewCell

        XCTAssertNotNil(cell, "The cell must be a ImageCollectionViewCell")

        let sameImageInstance = cell?.image === image

        XCTAssertTrue(sameImageInstance, "Missing binding with cell")
    }

    func testOnViewDidLoadStartLoadImages() {
        let spy = DetailViewModelSpy()
        let sut = makeSUT(viewModel: spy)

        sut.loadViewIfNeeded()

        XCTAssertEqual(spy.startLoadImagesInvocationsCount, 1, "Missing load image")
    }

    //MARK: Helpers

    private func makeSUT(title: String) -> DetailViewController {
        let sprites = SpritesFixture().makeSprites()
        let vm = DetailViewModel(title: title, sprites: sprites)
        return makeSUT(viewModel: vm)
    }

    private func makeSUT(viewModel: DetailViewModel = DummyDetailViewModel()) -> DetailViewController {
        DetailViewController(viewModel: viewModel)
    }

    private lazy var firstIndexPath = IndexPath(item: 0, section: 0)
}

private extension DetailViewController {

    var closeButton: UIButton? {
        view.subviews.first{ $0 is UIButton } as? UIButton
    }

    var titleLabel: UILabel? {
        view.subviews.first{ $0 is UILabel } as? UILabel
    }

    var collectionView: UICollectionView? {
        view.subviews.first{ $0 is UICollectionView } as? UICollectionView
    }
}

private class DummyDetailViewModel: DetailViewModel {

    init() {
        super.init(title: "", sprites: SpritesFixture().makeSprites())
    }

    override func numberOfItems(in section: Int) -> Int {
        0
    }

    override func item(at indexPath: IndexPath) -> DetailCellViewModel {
        DetailCellViewModel(image: UIImage())
    }
}

private class DetailViewModelSpy: DummyDetailViewModel {

    private(set) var startLoadImagesInvocationsCount = 0

    override func startLoadImages() {
        startLoadImagesInvocationsCount += 1
    }
}

private class OneItemViewModel: DummyDetailViewModel {

    private let image: UIImage

    init(image: UIImage = UIImage()) {
        self.image = image
        super.init()
    }

    override func numberOfItems(in section: Int) -> Int {
        1
    }

    override func item(at indexPath: IndexPath) -> DetailCellViewModel {
        DetailCellViewModel(image: image)
    }
}
