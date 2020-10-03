//
//  PokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import Foundation

protocol PokemonCatcher {

    func first()
    func next()

    func taskOngoingFor(for index: Int) -> Bool
}
