//
//  XCTAssert+Sprites.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import XCTest
@testable import Pokedex

func XCTAssertSpritesEqual(_ sprites1: Sprites?, _ sprites2: Sprites?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertDefaultImageEqual(sprites1?.frontDefault, sprites2?.frontDefault, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.frontShiny, sprites2?.frontShiny, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.frontFemale, sprites2?.frontFemale, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.frontShinyFemale, sprites2?.frontShinyFemale, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backDefault, sprites2?.backDefault, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backShiny, sprites2?.backShiny, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backFemale, sprites2?.backFemale, message(), file: file, line: line)
    XCTAssertImageEqual(sprites1?.backShinyFemale, sprites2?.backShinyFemale, message(), file: file, line: line)
}

private func XCTAssertDefaultImageEqual(_ defaultImage1: DefaultImage?, _ defaultImage2: DefaultImage?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(defaultImage1?.data, defaultImage2?.data, message(), file: file, line: line)
}

private  func XCTAssertImageEqual(_ image1: Image?, _ image2: Image?, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(image1?.data, image2?.data, message(), file: file, line: line)
    XCTAssertEqual(image1?.url, image2?.url, message(), file: file, line: line)
}

