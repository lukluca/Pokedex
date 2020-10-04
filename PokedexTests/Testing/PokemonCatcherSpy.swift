//  PokemonCatcherSpy.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 03/10/2020.
//
//

@testable import Pokedex

class PokemonCatcherSpy: PokemonCatcher {

    private(set) var firstPageInvocations = [(Result<PokemonList, Error>) -> Void]()
    private(set) var pageThatContainsInvocations = [[Int]]()
    private(set) var taskOngoingForInvocations = [Int]()

    func firstPage(completion: @escaping (Result<PokemonList, Error>) -> Void) {
        firstPageInvocations.append(completion)
    }

    func pageThatContains(indexes: [Int]) {
        pageThatContainsInvocations.append(indexes)
    }

    func taskOngoingFor(for index: Int) -> Bool {
        taskOngoingForInvocations.append(index)
        return false
    }
}
