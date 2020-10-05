//
//  RealmTestCase.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import XCTest
import RealmSwift

class RealmTestCase: XCTestCase {

    override func setUp() {
        super.setUp()

        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = self.name
    }

    func makeDatabase() throws -> Realm {
        try Realm()
    }
}
