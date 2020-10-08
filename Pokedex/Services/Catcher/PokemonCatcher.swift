//
//  PokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import Foundation

protocol PokemonCatcher {

    func firstPage(pageSize: Int, completion: @escaping (Result<PokemonList, Error>) -> Void)
    func page(pageSize: Int, number: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void)

    func taskOngoing(for index: Int) -> Bool

    func stopTask(for index: Int)
}
