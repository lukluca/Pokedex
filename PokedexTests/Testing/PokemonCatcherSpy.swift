//  PokemonCatcherSpy.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 03/10/2020.
//
//

@testable import Pokedex

class PokemonCatcherSpy: PokemonCatcher {

    private(set) var firstPageInvocations = [(Result<PokemonList, Error>) -> Void]()
    private(set) var pageThatContainsInvocations = [(indexes: [Int], completion: (Result<[Pokemon], Error>) -> Void)]()
    private(set) var taskOngoingForInvocations = [Int]()

    func firstPage(completion: @escaping (Result<PokemonList, Error>) -> Void) {
        firstPageInvocations.append(completion)
    }

    func pageThatContains(indexes: [Int], completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        pageThatContainsInvocations.append((indexes, completion))
    }

    func taskOngoingFor(for index: Int) -> Bool {
        taskOngoingForInvocations.append(index)
        return false
    }
}
