//
//  ImageCollectionViewCellTests.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 06/10/2020.
//
//

import XCTest
@testable import Pokedex

class ImageCollectionViewCellTests: XCTestCase {

    private let sut = ImageCollectionViewCell(frame: .zero)

    func testAppendCustomSubviews() throws {
        let image = sut.contentView.subviews.first as? UIImageView

        XCTAssertEqual(sut.contentView.subviews.count, 1, "The cell must have one subview")
        XCTAssertNotNil(image, "The cell must have an imageView")
    }

    func testSetImageSetsImageViewImage() {
        let image = UIImage()
        sut.image = image

        let sameInstance = sut.imageView?.image === image

        XCTAssertTrue(sameInstance, "Fail to set image on imageView")
    }
}

private extension ImageCollectionViewCell {
    var imageView: UIImageView? {
        contentView.subviews.first as? UIImageView
    }
}
