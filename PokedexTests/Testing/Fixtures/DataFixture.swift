//
//  DataFixture.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import Foundation

struct DataFixture {

    func makeRandomData() -> Data {
        let bytes = [UInt32](repeating: 0, count: 20).map { _ in arc4random() }
        return Data(bytes: bytes, count: 20)
    }

}

