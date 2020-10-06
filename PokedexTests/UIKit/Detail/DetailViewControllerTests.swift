//
//  DetailViewControllerTests.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 06/10/2020.
//
//

import XCTest
@testable import Pokedex

class DetailViewControllerTests: XCTestCase {

    @available(iOS 13.0, *)
    func testBackgroundColorForDarkAwareSystems() throws {
        try skipIfVersionAtLeast(iOS13)

        let sut = makeSUT()

        XCTAssertEqual(sut.view.backgroundColor, .systemBackground, "We want a systemBackground")
    }

    func testBackgroundColorIsWhite() throws {
        try skipIfVersionBelow(iOS13)

        let sut = makeSUT()

        XCTAssertEqual(sut.view.backgroundColor, .white, "We want a white background")
    }

    @available(iOS 13.0, *)
    func testDoesNotHaveACloseButton() throws  {
        try skipIfVersionAtLeast(iOS13)

        let sut = makeSUT()

        XCTAssertNil(sut.closeButton, "Use swipe down gesture instead")
    }

    func testDoesHaveACloseButton() throws  {
        try skipIfVersionBelow(iOS13)

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

    //MARK: Helpers

    private func makeSUT(title: String = "") -> DetailViewController {
        let vm = DetailViewModel(title: title)
        return DetailViewController(viewModel: vm)
    }
}

private extension DetailViewController {

    var closeButton: UIButton? {
        view.subviews.first{ $0 is UIButton } as? UIButton
    }

    var titleLabel: UILabel? {
        view.subviews.first{ $0 is UILabel } as? UILabel
    }
}
