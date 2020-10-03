//
//  DummyPokemonCatcher.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

@testable import Pokedex

class DummyPokemonCatcher: PokemonCatcher {
    func firstPage(completion: @escaping (Result<PokemonList, Error>) -> Void) {}

    func next() {}

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
