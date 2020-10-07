//
//  PokemonFixture.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import Foundation
@testable import Pokedex

class PokemonFixture {

    func makePokemon(id: Int, name: String, frontDefaultData: Data = Data(), frontShinyData: Data? = nil) -> Pokemon {
        let sprites = SpritesFixture().makeSprites(frontDefaultData: frontDefaultData)
        return Pokemon(id: id, name: name, sprites: sprites)
    }
}

class SpritesFixture {

    func makeSprites(frontDefaultData: Data = Data(), frontShinyData: Data? = nil) -> Sprites {
        let frontShiny: Image?
        if let data = frontShinyData {
            frontShiny = ImageFixture().makeImage(with: data)
        } else {
            frontShiny = nil
        }
        let img = ImageFixture().makeDefaultImage(with: frontDefaultData)
        return Sprites(frontDefault: img, frontShiny: frontShiny, frontFemale: nil, frontShinyFemale: nil, backDefault: nil, backShiny: nil, backFemale: nil, backShinyFemale: nil)
    }
}

class ImageFixture {

    func makeDefaultImage(with data: Data) -> DefaultImage {
        DefaultImage(data: data)
    }
    
    func makeImage(with data: Data) -> Image? {
        guard let url = URL(string: "https:www.foo.com") else {
            return nil
        }
        return Image(data: data, url: url)
    }
}
