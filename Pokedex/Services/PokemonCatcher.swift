//
//  PokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import Foundation

protocol PokemonCatcher {

    func firstPage(completion: @escaping (Result<PokemonList, Error>) -> Void)
    func pageThatContains(indexes: [Int])

    func taskOngoingFor(for index: Int) -> Bool
}
