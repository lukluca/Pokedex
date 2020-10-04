//
//  DummyPokemonCatcher.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

@testable import Pokedex

class DummyPokemonCatcher: PokemonCatcher {
    func firstPage(completion: @escaping (Result<PokemonList, Error>) -> Void) {}

    func pageThatContains(indexes: [Int], completion: @escaping (Result<[Pokemon], Error>) -> Void) {}

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
