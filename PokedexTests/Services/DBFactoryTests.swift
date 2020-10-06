//
//  DBFactoryTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import XCTest
import RealmSwift
@testable import Pokedex

class DBFactoryTests: XCTest {

    func testMakesRealmConfiguredWithLibraryDirectoryFileUrl() {
        let sut = DBFactory()

        let db = sut.make()

        XCTAssertNotNil(db)
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("pokedex.realm")
        XCTAssertEqual(db?.configuration.fileURL, url)
    }
}
