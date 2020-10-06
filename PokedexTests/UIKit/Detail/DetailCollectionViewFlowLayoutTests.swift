//
//  DetailCollectionViewFlowLayoutTests.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 06/10/2020.
//
//

import XCTest
@testable import Pokedex

class DetailCollectionViewFlowLayoutTests: XCTestCase {

    func testInitWithRequiredProperties() {
        let sut = DetailCollectionViewFlowLayout()

        XCTAssertEqual(sut.scrollDirection, .horizontal, "Missing Layout configuration")
        XCTAssertEqual(sut.minimumInteritemSpacing, 20, "Missing Layout configuration")
        XCTAssertEqual(sut.sectionInset, UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), "Missing Layout configuration")
    }
}
