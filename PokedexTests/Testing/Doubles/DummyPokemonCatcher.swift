//
//  DummyPokemonCatcher.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

@testable import Pokedex

class DummyPokemonCatcher: PokemonCatcher {

    func firstPage(pageSize: Int, completion: @escaping (Result<PokemonList, Error>) -> Void) {}

    func page(pageSize: Int, number: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void) {}

    func taskOngoing(for index: Int) -> Bool {
        false
    }

    func stopTask(pageSize: Int, for index: Int) {}
}
