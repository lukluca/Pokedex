//  PokemonCatcherSpy.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 03/10/2020.
//
//

@testable import Pokedex

class PokemonCatcherSpy: PokemonCatcher {

    private(set) var firstInvocations = [(Result<PokemonList, Error>) -> Void]()

    func first(completion: @escaping (Result<PokemonList, Error>) -> Void) {
        firstInvocations.append(completion)
    }

    func next() {}

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
