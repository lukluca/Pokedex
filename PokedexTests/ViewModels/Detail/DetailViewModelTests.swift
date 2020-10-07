//
//  DetailViewModelTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import XCTest
@testable import Pokedex

class DetailViewModelTests: XCTestCase {

    func testOnInitDataSourceIsEmpty() {
        let sut = makeSUT(frontDefaultData: Data())

        XCTAssertEqual(sut.numberOfItems(in: 0), 0)
    }
    
    func testOnInitDataSourceIsEmptyIfIsNotPossibleToGenerateDefaultImageAfterStartingLoadImage() {
        let sut = makeSUT(frontDefaultData: Data())
        
        sut.startLoadImages()

        XCTAssertEqual(sut.numberOfItems(in: 0), 0)
    }

    func testDataSourceIsNotEmptyIfIsPossibleToGenerateDefaultImageAfterStartingLoadImage() throws {
        let data = try UIImage.imageResourceAsData(insideBundleOf: DetailViewModel.self)
        let sut = makeSUT(frontDefaultData: data)
        
        sut.startLoadImages()

        XCTAssertEqual(sut.numberOfItems(in: 0), 1)
        
        let item = sut.item(at: IndexPath(item: 0, section: 0))
        
        XCTAssertImageEqualToData(item.image, data, "Failed to make default image from sprite")
    }
    
    func testDataSourceIsNotEmptyIfIsPossibleToGenerateImagesAfterStartingLoadImage() throws {
        let data = try UIImage.imageResourceAsData(insideBundleOf: DetailViewModel.self)
        let sut = makeSUT(frontDefaultData: data, frontShinyData: data)
        
        sut.startLoadImages()

        XCTAssertEqual(sut.numberOfItems(in: 0), 2)
        
        let firstItem = sut.item(at: IndexPath(item: 0, section: 0))
        let secondItem = sut.item(at: IndexPath(item: 0, section: 1))
        
        XCTAssertImageEqualToData(firstItem.image, data, "Failed to make default image from sprite")
        XCTAssertImageEqualToData(secondItem.image, data, "Failed to make image from sprite")
    }

    //MARK: Helpers

    private func makeSUT(frontDefaultData: Data, frontShinyData: Data? = nil) -> DetailViewModel {
        let sprites = SpritesFixture().makeSprites(frontDefaultData: frontDefaultData, frontShinyData: frontShinyData)
        return DetailViewModel(title: "", sprites: sprites)
    }
}
