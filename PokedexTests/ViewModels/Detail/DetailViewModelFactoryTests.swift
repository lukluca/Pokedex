//
//  DetailViewModelFactoryTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 9/10/2020.
//

import XCTest
@testable import Pokedex

class DetailViewModelFactoryTests: XCTestCase {

    func testMakesViewModel() {
        let sut = DetailViewModelFactory()

        let title = "titleFoo"
        let sprites = SpritesFixture().makeSprites()
        let details = DetailsFixture().make(baseExperience: 10, height: 35, weight: 50)
        let vm = sut.make(id: 1, title: title, sprites: sprites, details: details)

        XCTAssertEqual(vm.title, title)
        XCTAssertEqual(vm.number, "Number: 2")
        XCTAssertEqual(vm.baseExperience, "Base Experience: 10")
        XCTAssertEqual(vm.height, "Height: 35")
        XCTAssertEqual(vm.weight, "Weight: 50")
    }
}
