//
//  XCTest+ImageEqualToData.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 07/10/2020.
//

import XCTest

func XCTAssertImageEqualToData(_ image: UIImage?, _ data: Data, _ message: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(image?.pngData(), UIImage(data: data)?.pngData(), file: file, line: line)
}


