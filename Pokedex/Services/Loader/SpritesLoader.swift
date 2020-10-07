//
//  SpritesLoader.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 7/10/2020.
//

import Foundation

protocol SpritesLoader: class {

    var onDataLoad: ((Data) -> ())? { get set }

    func loadIfNeeded(sprites: Sprites)
    func stopLoad()
}
