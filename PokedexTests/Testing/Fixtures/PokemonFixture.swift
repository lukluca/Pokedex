//
//  PokemonFixture.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import Foundation
@testable import Pokedex

class PokemonFixture {

    func makePokemon(id: Int, name: String, frontDefaultData: Data = Data()) -> Pokemon {
        let sprites = SpritesFixture().makeSprites(frontDefaultData: frontDefaultData)
        return Pokemon(id: id, name: name, sprites: sprites)
    }
}

class SpritesFixture {

    func makeSprites(frontDefaultData: Data) -> Sprites {
        let img = ImageFixture().makeDefaultImage(with: frontDefaultData)
        return Sprites(frontDefault: img, frontShiny: nil, frontFemale: nil, frontShinyFemale: nil, backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil)
    }
}

class ImageFixture {

    func makeDefaultImage(with data: Data) -> DefaultImage {
        DefaultImage(data: data)
    }
}
