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

    func testDoesHaveACloseButton() throws  {
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

    func testDoesHaveAScrollView() {
        let sut = makeSUT()

        XCTAssertNotNil(sut.scrollView)
    }

    func testScrollViewHasOnlyOneSubview() {
        let sut = makeSUT()

        XCTAssertEqual(sut.scrollView?.subviews.count, 1)
        XCTAssertNotNil(sut.scrollView?.containerView)
    }

    func testContainerViewOfScrollViewHasACollectionViewAndAStackView() {
        let sut = makeSUT()

        XCTAssertEqual(sut.scrollView?.containerView?.subviews.count, 2)
        XCTAssertNotNil(sut.scrollView?.containerView?.collectionView)
        XCTAssertNotNil(sut.scrollView?.containerView?.stackView)
    }

    func testStackViewHasGotThreeLabelsAsArrangedSubviews() {
        let sut = makeSUT()

        let stackView = sut.scrollView?.containerView?.stackView

        XCTAssertEqual(stackView?.arrangedSubviews.count, 4)
        XCTAssertNotNil(stackView?.arrangedSubviews.first as? UILabel)
        XCTAssertNotNil(stackView?.arrangedSubviews[1] as? UILabel)
        XCTAssertNotNil(stackView?.arrangedSubviews[2] as? UILabel)
        XCTAssertNotNil(stackView?.arrangedSubviews.last as? UILabel)
    }

    func testConfiguresStackView() {
        let sut = makeSUT()

        let stackView = sut.scrollView?.containerView?.stackView

        XCTAssertEqual(stackView?.axis, .vertical, "Missing stack view configuration")
        XCTAssertEqual(stackView?.spacing, 5, "Missing stack view configuration")
        XCTAssertEqual(stackView?.alignment, .center, "Missing stack view configuration")
    }

    func testBindsStackViewLabelsWhitViewModel() {
        let sut = makeSUT(number: "5",
                baseExperience: "40",
                height: "100",
                weight: "3")

        let stackView = sut.scrollView?.containerView?.stackView

        let firstLabel = stackView?.arrangedSubviews.first as? UILabel
        let secondLabel = stackView?.arrangedSubviews[1] as? UILabel
        let thirdLabel = stackView?.arrangedSubviews[2] as? UILabel
        let fourthLabel = stackView?.arrangedSubviews.last as? UILabel

        XCTAssertEqual(firstLabel?.text, "Number: 5", "Missing stack view binding")
        XCTAssertEqual(secondLabel?.text, "Base Experience: 40", "Missing stack view binding")
        XCTAssertEqual(thirdLabel?.text, "Height: 100", "Missing stack view binding")
        XCTAssertEqual(fourthLabel?.text, "Weight: 3", "Missing stack view binding")
    }

    func testRegisterImageCell() throws {
        try skipIfVersionBelow(iOS11, "For some reason on iOS 11 the dequeueReusableCell causes a crash of the test suite.")

        let sut = makeSUT()
        let cell = sut.scrollView?.containerView?.collectionView?.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: firstIndexPath) as? ImageCollectionViewCell

        XCTAssertNotNil(cell, "The ImageCell must be registered")
    }

    func testConfiguresCollection() {
        let sut = makeSUT()

        let collectionView = sut.scrollView?.containerView?.collectionView

        XCTAssertEqual(collectionView?.backgroundColor, .clear)
        XCTAssertEqual(collectionView?.contentInsetAdjustmentBehavior, .always)
        let dataSource = collectionView?.dataSource as? DetailViewController
        XCTAssertEqual(dataSource, sut, "Missing set dataSource delegate")
    }

    func testBindingCellFromCellViewModel() throws {
        let image = UIImage()
        let viewModel = OneItemViewModel(image: image)

        let sut = makeSUT(viewModel: viewModel)

        guard let collectionView = sut.scrollView?.containerView?.collectionView else {
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

        XCTAssertEqual(spy.startLoadImagesInvocationsCount, 1, "Missing start load image")
    }

    func testOnViewWillAppearAttachesToViewModelUpdates() {
        let spy = DetailViewModelSpy()
        let sut = makeSUT(viewModel: spy)

        sut.viewWillAppear(false)

        XCTAssertNotNil(spy.onItemAdded, "Missing attach to view model update")
    }

    func testOnViewWillDisappearStopLoadImages() {
        let spy = DetailViewModelSpy()
        let sut = makeSUT(viewModel: spy)

        sut.viewWillDisappear(false)

        XCTAssertEqual(spy.stopLoadImagesInvocationsCount, 1, "Missing stop load image")
    }

    func testOnViewWillDisappearDetachesToViewModelUpdates() {
        let spy = DetailViewModelSpy()
        let sut = makeSUT(viewModel: spy)

        sut.loadViewIfNeeded()

        sut.viewWillDisappear(false)

        XCTAssertNil(spy.onItemAdded, "Missing detach to view model update")
    }

    //MARK: Helpers

    private func makeSUT(number: String = "",
                         title: String = "",
                         baseExperience: String = "",
                         height: String = "",
                         weight: String = "") -> DetailViewController {
        let sprites = SpritesFixture().makeSprites()
        let vm = DetailViewModel(number: number,
                title: title,
                baseExperience: baseExperience,
                height: height,
                weight: weight,
                sprites: sprites,
                loader: DummySpritesLoader())
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

    var scrollView: UIScrollView? {
        view.subviews.first{ $0 is UIScrollView } as? UIScrollView
    }
}

private extension UIScrollView {
    var containerView: UIView? {
        subviews.first
    }
}

private extension UIView {
    var collectionView: UICollectionView? {
        subviews.first{ $0 is UICollectionView } as? UICollectionView
    }

    var stackView: UIStackView? {
        subviews.first{ $0 is UIStackView } as? UIStackView
    }
}

private class DummyDetailViewModel: DetailViewModel {

    init() {
        super.init(number: "",
                title: "",
                baseExperience: "",
                height: "",
                weight: "",
                sprites: SpritesFixture().makeSprites(),
                loader: DummySpritesLoader())
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
    private(set) var stopLoadImagesInvocationsCount = 0

    override func startLoadImages() {
        startLoadImagesInvocationsCount += 1
    }

    override func stopLoadImages() {
        stopLoadImagesInvocationsCount += 1
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
