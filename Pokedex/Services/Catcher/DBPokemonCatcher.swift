//
//  DBPokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import RealmSwift

enum DBError: Error {
    case firstPokemons
    case nextPagePokemons
}

class DBPokemonCatcher: PokemonCatcher {

    private let nextHandler: PokemonCatcher

    private let db: Realm?

    init(db: Realm?, nextHandler: PokemonCatcher) {
        self.db = db
        self.nextHandler = nextHandler
    }

    func firstPage(pageSize: Int, completion: @escaping (Result<PokemonList, Error>) -> Void) {
        let pokemonsResults = db?.objects(DBPokemon.self)
        let pokedexResults = db?.objects(DBPokedex.self)

        guard let entities = pokemonsResults, !entities.isEmpty, let entityPokedex = pokedexResults?.first else {
            nextHandler.firstPage(pageSize: pageSize, completion: completion)
            return
        }

        let pokemonsInsideFirstPage = readPokemonsInsidePage(pageSize: pageSize, number: 0, from: entities)

        guard !pokemonsInsideFirstPage.isEmpty else {
            completion(Result.failure(DBError.firstPokemons))
            return
        }

        let list = PokemonList(totalPokemonCount: entityPokedex.totalPokemonCount, pokemons: Array(pokemonsInsideFirstPage))
        completion(Result.success(list))
    }

    private func convert(_ entities: [DBPokemon]) -> [Pokemon] {
        entities.compactMap { [weak self] (entity: DBPokemon) -> Pokemon? in
            self?.convert(entity)
        }
    }

    private func convert(_ entity: DBPokemon) -> Pokemon {
        Pokemon(id: entity.id, name: entity.name, imageData: entity.imageData)
    }

    func page(pageSize: Int, number: Int, completion: @escaping (Result<[Pokemon], Error>) -> Void) {
        let results = db?.objects(DBPokemon.self)

        guard let entities = results, !entities.isEmpty else {
            completion(Result.failure(DBError.nextPagePokemons))
            return
        }

        let pokemonsInsidePage = readPokemonsInsidePage(pageSize: pageSize, number: number, from: entities)

        guard !pokemonsInsidePage.isEmpty else {
            nextHandler.page(pageSize: pageSize, number: number, completion: completion)
            return
        }

        completion(Result.success(pokemonsInsidePage))
    }

    private func readPokemonsInsidePage(pageSize: Int, number: Int, from entities: Results<DBPokemon>) -> [Pokemon] {
        let entitiesInsidePage = read(pageSize: pageSize, number: number, from: entities)
        return convert(entitiesInsidePage)
    }

    private func read(pageSize: Int, number: Int, from entities: Results<DBPokemon>) -> [DBPokemon] {
        let entitiesInsidePage = entities.filter { (pokemon: DBPokemon) -> Bool in
            pokemon.id >= (number * pageSize) && pokemon.id < ((number + 1) * pageSize)
        }

        return Array(entitiesInsidePage)
    }

    func taskOngoingFor(for index: Int) -> Bool {
        nextHandler.taskOngoingFor(for: index)
    }
}
