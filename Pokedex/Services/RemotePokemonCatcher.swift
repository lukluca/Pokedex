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

class RemotePokemonCatcher: PokemonCatcher {

    private let pageSize: Int

    private let pokemonAPI = PokemonAPI()

    init(pageSize: Int) {
        self.pageSize = pageSize
    }

    func first(completion: @escaping (Result<PokemonList, Error>) -> Void) {
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

                var pokemons = [Pokemon]()
                var fulfilledResourceCount = 0

                resources.forEach { (resource: PKMNamedAPIResource<PKMPokemon>) in
                    self.pokemonAPI.resourceService.fetch(resource) { (result: Result<PKMPokemon, Error>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let pkm):
                                guard let sprite = pkm.sprites?.frontDefault, let spriteURL = URL(string: sprite) else {
                                    return
                                }

                                self.downloadImage(from: spriteURL) { image in
                                    DispatchQueue.main.async {
                                        fulfilledResourceCount += 1
                                        guard let pokemon = self.convert(pkm, image: image) else {
                                            self.tryToComplete(whit: fulfilledResourceCount, resources: resources, pokemons: pokemons, totalCount: totalCount, completion: completion)
                                            return
                                        }
                                        pokemons.append(pokemon)
                                        self.tryToComplete(whit: fulfilledResourceCount, resources: resources, pokemons: pokemons, totalCount: totalCount, completion: completion)
                                    }
                                }
                            case .failure:
                                fulfilledResourceCount += 1
                                self.tryToComplete(whit: fulfilledResourceCount, resources: resources, pokemons: pokemons, totalCount: totalCount, completion: completion)
                            }
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(Result.failure(error))
                }
            }
        }
    }

    private func convert(_ resource: PKMPokemon, image: UIImage?) -> Pokemon? {
        guard let name = resource.name else {
            return nil
        }
        guard let id = resource.id else {
            return nil
        }

        guard let img = image else {
            return nil
        }

        return Pokemon(id: id, name: name, image: img)
    }

    private func downloadImage(from url: URL,  completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> () in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }

        task.resume()
    }

    private func tryToComplete(whit fulfilledResourceCount: Int, resources: [PKMNamedAPIResource<PKMPokemon>], pokemons: [Pokemon], totalCount: Int, completion: @escaping (Result<PokemonList, Error>) -> Void) {
        if fulfilledResourceCount == resources.count {
            let list = PokemonList(totalPokemonCount: totalCount, pokemons: pokemons)
            completion(Result.success(list))
        }
    }

    func next() {

    }

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
