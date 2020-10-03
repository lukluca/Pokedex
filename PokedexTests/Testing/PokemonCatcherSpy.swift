//  PokemonCatcherSpy.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 03/10/2020.
//
//

@testable import Pokedex

class PokemonCatcherSpy: PokemonCatcher {

    private(set) var firstPageInvocations = [(Result<PokemonList, Error>) -> Void]()

    func firstPage(completion: @escaping (Result<PokemonList, Error>) -> Void) {
        firstPageInvocations.append(completion)
    }

    func next() {}

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
