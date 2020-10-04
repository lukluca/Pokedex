//
//  DBPokemonCatcher.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import RealmSwift
import UIKit

enum DBError: Error {
    case firstPokemons
    case nextPagePokemons
}

//MARK: Realm Objects

class DBPokemon: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var imageData = Data()

    override static func primaryKey() -> String? {
        "id"
    }
}

class DBPokedex: Object {
    @objc dynamic var totalPokemonCount = 0
}

class DBPokemonList: Object {
    dynamic var pokemons = List<DBPokemon>()
}

//MARK: DBPokemonCatcher
class DBPokemonCatcher: PokemonCatcher {

    private let nextHandler: PokemonCatcher

    private var database: Realm? {
        try? Realm()
    }

    init(nextHandler: PokemonCatcher) {
        self.nextHandler = nextHandler
    }

    func firstPage(pageSize: Int, completion: @escaping (Result<PokemonList, Error>) -> Void) {
        let listResults = database?.objects(DBPokemonList.self)
        let pokedexResults = database?.objects(DBPokedex.self)

        guard let entityList = listResults?.first, !entityList.pokemons.isEmpty, let entityPokedex = pokedexResults?.first else {
            nextHandler.firstPage(pageSize: pageSize, completion: completion)
            return
        }

        let pokemonsInsideFirstPage = readPokemonsInsidePage(pageSize: pageSize, number: 0, from: entityList)

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
        let results = database?.objects(DBPokemonList.self)

        guard let entityList = results?.first, !entityList.pokemons.isEmpty else {
            completion(Result.failure(DBError.nextPagePokemons))
            return
        }

        let pokemonsInsidePage = readPokemonsInsidePage(pageSize: pageSize, number: number, from: entityList)

        guard !pokemonsInsidePage.isEmpty else {
            nextHandler.page(pageSize: pageSize, number: number, completion: completion)
            return
        }

        completion(Result.success(pokemonsInsidePage))
    }

    private func readPokemonsInsidePage(pageSize: Int, number: Int, from entityList: DBPokemonList) -> [Pokemon] {
        let entitiesInsidePage = read(pageSize: pageSize, number: number, from: entityList)
        return convert(entitiesInsidePage)
    }

    private func read(pageSize: Int, number: Int, from entityList: DBPokemonList) -> [DBPokemon] {
        let entitiesInsidePage = entityList.pokemons.filter { (pokemon: DBPokemon) -> Bool in
            pokemon.id >= (number * pageSize) && pokemon.id < ((number + 1) * pageSize)
        }

        return Array(entitiesInsidePage)
    }

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
