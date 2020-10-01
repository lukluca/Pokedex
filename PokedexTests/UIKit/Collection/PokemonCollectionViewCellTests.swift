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
}

private extension PokemonCollectionViewCell {
    
    var imageView: UIImageView? {
        contentView.subviews.first as? UIImageView
    }
    
    var label: UILabel? {
        contentView.subviews.last as? UILabel
    }
}
