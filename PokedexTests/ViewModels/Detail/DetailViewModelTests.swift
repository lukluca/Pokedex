//
//  DetailViewModelTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import XCTest
@testable import Pokedex

enum DetailViewModelTestsError: Error {
    case failedMakeURL
}

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

    func testLoadIfNeededAllTheSpritesType() throws {
        guard let url = URL(string: "https:www.foo.com") else {
            throw DetailViewModelTestsError.failedMakeURL
        }

        let image = ImageFixture().makeImage(data: nil, url: url)
        let sprites = SpritesFixture().makeSprites(frontShiny: image)
        let spy = SpritesLoaderSpy()
        let sut = makeSUT(sprites: sprites, loader: spy)

        sut.startLoadImages()

        XCTAssertNotNil(spy.onDataLoad, "Missing attach to loader event")
        XCTAssertEqual(spy.loadIfNeededInvocations.count, 7)
        XCTAssertSpritesEqual(spy.loadIfNeededInvocations.first?.sprites, sprites)
        XCTAssertEqual(spy.loadIfNeededInvocations.first?.type, .frontShiny)
        XCTAssertSpritesEqual(spy.loadIfNeededInvocations[1].sprites, sprites)
        XCTAssertEqual(spy.loadIfNeededInvocations[1].type, .frontFemale)
        XCTAssertSpritesEqual(spy.loadIfNeededInvocations[2].sprites, sprites)
        XCTAssertEqual(spy.loadIfNeededInvocations[2].type, .frontShinyFemale)
        XCTAssertSpritesEqual(spy.loadIfNeededInvocations[3].sprites, sprites)
        XCTAssertEqual(spy.loadIfNeededInvocations[3].type, .backDefault)
        XCTAssertSpritesEqual(spy.loadIfNeededInvocations[4].sprites, sprites)
        XCTAssertEqual(spy.loadIfNeededInvocations[4].type, .backShiny)
        XCTAssertSpritesEqual(spy.loadIfNeededInvocations[5].sprites, sprites)
        XCTAssertEqual(spy.loadIfNeededInvocations[5].type, .backFemale)
        XCTAssertSpritesEqual(spy.loadIfNeededInvocations.last?.sprites, sprites)
        XCTAssertEqual(spy.loadIfNeededInvocations.last?.type, .backShinyFemale)
    }

    func testStopsLoadImage() {
        let spy = SpritesLoaderSpy()
        let sut = makeSUT(loader: spy)

        sut.stopLoadImages()

        XCTAssertEqual(spy.stopLoadInvocationsCount, 1)
    }

    //MARK: Helpers

    private func makeSUT(frontDefaultData: Data,
                         frontShinyData: Data? = nil) -> DetailViewModel {
        let sprites = SpritesFixture().makeSprites(frontDefaultData: frontDefaultData, frontShinyData: frontShinyData)
        return DetailViewModel(title: "", sprites: sprites, loader: DummySpritesLoader())
    }

    private func makeSUT(loader: SpritesLoader = DummySpritesLoader()) -> DetailViewModel {
        let sprites = SpritesFixture().makeSprites()
        return DetailViewModel(title: "", sprites: sprites, loader: loader)
    }

    private func makeSUT(sprites: Sprites,
                         loader: SpritesLoader = DummySpritesLoader()) -> DetailViewModel {
        DetailViewModel(title: "", sprites: sprites, loader: loader)
    }
}

private class SpritesLoaderSpy: SpritesLoader {

    private(set) var loadIfNeededInvocations = [(sprites: Sprites, type: SpritesType)]()
    private(set) var stopLoadInvocationsCount = 0

    var onDataLoad: ((Data) -> ())?

    func loadIfNeeded(sprites: Sprites, of type: SpritesType) {
        loadIfNeededInvocations.append((sprites, type))
    }

    func stopLoad() {
        stopLoadInvocationsCount += 1
    }
}

//TODO move maybe, now is useless
private class DataDownloaderSpy: DataDownloader {

    var downloadInvocations = [(url: URL, completion: (Data?) -> Void)]()

    func download(from url: URL, completion: @escaping (Data?) -> Void) -> URLSessionDataTask {
        downloadInvocations.append((url, completion))
        return URLSessionDataTask()
    }
}
