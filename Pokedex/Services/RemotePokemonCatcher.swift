//
//  RemotePokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import PokemonAPI

enum RemoteError: Error {
    case firstPokemons
}

struct RemotePokemon {
    let id: Int?
    let name: String?
    let imageURL: String?
}

struct RemotePokemonList {
    let totalPokemonCount: Int?
    let pokemons: [RemotePokemon]
}

class RemotePokemonCatcher: PokemonCatcher {

    private let pageSize: Int

    private let pokemonAPI = PokemonAPI()

    init(pageSize: Int) {
        self.pageSize = pageSize
    }

    func first(completion: @escaping (Result<PokemonList, Error>) -> Void) {
        firstPageFromAPI { result in
            switch result {
            case .success(let remoteList):
                var pokemons = [Pokemon]()
                var fulfillmentCount = 0
                remoteList.pokemons.forEach { [weak self] (pokemon: RemotePokemon) -> () in
                    guard let self = self else {
                        return
                    }
                    guard let imageURL = pokemon.imageURL, let url = URL(string: imageURL) else {
                        return
                    }
                    self.downloadData(from: url) { data in
                        fulfillmentCount += 1
                        guard let data = data else {
                            return
                        }
                        guard let pkm = self.convert(pokemon, data: data) else {
                            return
                        }

                        pokemons.append(pkm)

                        if fulfillmentCount == remoteList.pokemons.count, let count = remoteList.totalPokemonCount {
                            let list = PokemonList(totalPokemonCount: count, pokemons: pokemons)
                            DispatchQueue.main.async {
                                completion(Result.success(list))
                            }
                        }
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(Result.failure(RemoteError.firstPokemons))
                }
            }
        }
    }

    private func firstPageFromAPI(completion: @escaping (Result<RemotePokemonList, Error>) -> Void) {
        let state = PaginationState<PKMPokemon>.initial(pageLimit: pageSize)
        pokemonAPI.pokemonService.fetchPokemonList(paginationState: state) { [weak self] (result: Result<PKMPagedObject<PKMPokemon>, Error>) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let page):
                guard let totalCount = page.count else {
                    completion(Result.failure(RemoteError.firstPokemons))
                    return
                }

                guard let resources = page.results as? [PKMNamedAPIResource<PKMPokemon>] else {
                    completion(Result.failure(RemoteError.firstPokemons))
                    return
                }

                var pokemons = [RemotePokemon]()
                var fulfilledResourceCount = 0

                resources.forEach { (resource: PKMNamedAPIResource<PKMPokemon>) in
                    self.pokemonAPI.resourceService.fetch(resource) { (result: Result<PKMPokemon, Error>) in
                        fulfilledResourceCount += 1
                        switch result {
                        case .success(let pkm):
                            pokemons.append(self.convert(pkm))
                        case .failure: ()
                        }

                        if fulfilledResourceCount == resources.count {
                            let list = RemotePokemonList(totalPokemonCount: totalCount, pokemons: pokemons)
                            completion(Result.success(list))
                        }
                    }
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
    }

    private func convert(_ resource: PKMPokemon) -> RemotePokemon {
        RemotePokemon(id: resource.id, name: resource.name, imageURL: resource.sprites?.frontDefault)
    }

    private func convert(_ resource: RemotePokemon, data: Data?) -> Pokemon? {
        guard let id = resource.id,
              let name = resource.name,
              let imageData = data else {
            return nil
        }

        return Pokemon(id: id, name: name, imageData: imageData)
    }

    private func downloadData(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = pokemonAPI.session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> () in
            completion(data)
        }

        task.resume()
    }

    func next() {

    }

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
