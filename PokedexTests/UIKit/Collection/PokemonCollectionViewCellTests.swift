//
//  PokemonCollectionViewCellTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 01/10/2020.
//

import XCTest
@testable import Pokedex

class PokemonCollectionViewCellTests: XCTestCase {
    
    private let sut = PokemonCollectionViewCell(frame: .zero)

    func testAppendCustomSubviews() throws {
        let image = sut.contentView.subviews.first as? UIImageView
        let label = sut.contentView.subviews.last as? UILabel
        
        XCTAssertEqual(sut.contentView.subviews.count, 2, "The cell must have two subviews")
        XCTAssertNotNil(image, "The cell must have an imageView")
        XCTAssertNotNil(label, "The cell must have a label")
    }
    
    func testSetNameSetsLabelText() {
        sut.name = "foo"
        
        XCTAssertEqual(sut.label?.text, "foo", "Fail to set name text")
    }
    
    func testSetImageSetsImageViewImage() {
        let image = UIImage()
        sut.image = image
        
        let sameInstance = sut.imageView?.image === image
        
        XCTAssertTrue(sameInstance, "Fail to set image on imageView")
    }

    func testStartsAnimationIfThereIsNoImageSet() {
        XCTAssertNil(sut.image)

        sut.startAnimateIfNeeded()

        let animation = sut.imageView?.layer.animation(forKey: "pulse") as? CABasicAnimation

        XCTAssertNotNil(sut.imageView?.backgroundColor)
        XCTAssertNotNil(animation, "Pulse animation not started")
        XCTAssertEqual(animation?.keyPath, "opacity")
        XCTAssertEqual(animation?.duration, 3)
        XCTAssertEqual(animation?.fromValue as? CGFloat, 0.3)
        XCTAssertEqual(animation?.toValue as? CGFloat, 0.7)
        XCTAssertEqual(animation?.timingFunction, CAMediaTimingFunction(name: .easeInEaseOut))
        XCTAssertTrue(animation!.autoreverses)
        XCTAssertEqual(animation?.repeatCount, .greatestFiniteMagnitude)
    }

    func testStopsAnimationIfThereIsImageSet() {
        sut.startAnimateIfNeeded()

        sut.image = UIImage()

        let animation = sut.imageView?.layer.animation(forKey: "pulse")

        XCTAssertNil(sut.imageView?.backgroundColor)
        XCTAssertNil(animation, "Pulse animation not stopped")
    }

    func testStopAnimation() {
        sut.startAnimateIfNeeded()
        sut.stopAnimate()

        let animation = sut.imageView?.layer.animation(forKey: "pulse")

        XCTAssertNil(sut.imageView?.backgroundColor)
        XCTAssertNil(animation, "Pulse animation not stopped")
    }

    func testStartsAnimateIfNilImageIsSet() {
        sut.image = UIImage()

        sut.image = nil

        let animation = sut.imageView?.layer.animation(forKey: "pulse")
        XCTAssertNotNil(animation)
        XCTAssertNotNil(sut.imageView?.backgroundColor)
        XCTAssertNil(sut.imageView?.image)
    }
}

private extension PokemonCollectionViewCell {
    
    var imageView: UIImageView? {
        contentView.subviews.first as? UIImageView
    }
    
    var label: UILabel? {
        contentView.subviews.last as? UILabel
    }
}
