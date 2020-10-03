//
//  RemotePokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import Foundation

class RemotePokemonCatcher: PokemonCatcher {
    func first(completion: @escaping (Result<[Pokemon], Error>) -> Void) {

    }

    func next() {

    }

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
