//
//  DummySpritesLoader.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 8/10/2020.
//

import Foundation
@testable import Pokedex

//TODO move
class DummySpritesLoader: SpritesLoader {
    var onDataLoad: ((Data) -> ())?

    func loadIfNeeded(sprites: Sprites, of type: SpritesType) {
    }

    func stopLoad() {
    }
}
