//  PokemonCatcherSpy.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 03/10/2020.
//
//

@testable import Pokedex

class PokemonCatcherSpy: PokemonCatcher {

    private(set) var firstPageInvocations = [(pageSize: Int, completion: (Result<PokemonList, Error>) -> Void)]()
    private(set) var pageInvocations = [(pageSize: Int, number: Int, completion: (Result<[Pokemon], Error>) -> Void)]()
    private(set) var taskOngoingForInvocations = [Int]()
    private(set) var stopTaskInvocations = [(pageSize: Int, index: Int)]()


    func firstPage(pageSize: Int, completion: @escaping (Result<PokemonList, Error>) -> Void) {
        firstPageInvocations.append((pageSize, completion))
    }

    func page(pageSize: Int, number: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        pageInvocations.append((pageSize, number, completion))
    }

    func taskOngoing(for index: Int) -> Bool {
        taskOngoingForInvocations.append(index)
        return false
    }

    func stopTask(pageSize: Int, for index: Int) {
        stopTaskInvocations.append((pageSize, index))
    }
}
