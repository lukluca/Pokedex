//  PokemonCatcherSpy.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 03/10/2020.
//
//

@testable import Pokedex

class PokemonCatcherSpy: PokemonCatcher {

    private(set) var firstInvocations = [(Result<[Pokemon], Error>) -> Void]()

    func first(completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        firstInvocations.append(completion)
    }

    func next() {}

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
