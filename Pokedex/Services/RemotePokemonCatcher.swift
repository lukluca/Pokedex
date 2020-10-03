//
//  RemotePokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import PokemonAPI

class RemotePokemonCatcher: PokemonCatcher {

    private let pageSize: Int

    init(pageSize: Int) {
        self.pageSize = pageSize
    }

    func first(completion: @escaping (Result<PokemonList, Error>) -> Void) {
        let state = PaginationState<PKMPokemon>.initial(pageLimit: pageSize)
        PokemonAPI().pokemonService.fetchPokemonList(paginationState: state) { (result: Result<PKMPagedObject<PKMPokemon>, Error>) in
            switch result {
            case .success(let page): ()
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    func next() {

    }

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
