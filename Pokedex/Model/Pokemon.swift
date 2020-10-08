//
//  Pokemon.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import UIKit

struct Pokemon {
    let id: Int
    let name: String
    let sprites: Sprites
    let details: Details
}

struct Details {
    let baseExperience: Int
    let height: Int
    let weight: Int
}

struct Sprites {
    let frontDefault: DefaultImage
    let frontShiny: Image?
    let frontFemale: Image?
    let frontShinyFemale: Image?
    let backDefault: Image?
    let backShiny: Image?
    let backFemale: Image?
    let backShinyFemale: Image?
}

struct Image {
    let data: Data?
    let url: URL
}

struct DefaultImage {
    let data: Data
}
