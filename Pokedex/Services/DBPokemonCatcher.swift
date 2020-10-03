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
}

class DBPokemon: Object {
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var imageData = Data()

    override static func primaryKey() -> String? {
        "id"
    }
}

class DBPokemonList: Object {
    @objc dynamic var totalPokemonCount = 0
    dynamic var pokemons = List<DBPokemon>()
}

class DBPokemonCatcher: PokemonCatcher {

    private let pageSize: Int
    private let nextHandler: PokemonCatcher

    private var database: Realm? {
        try? Realm()
    }

    init(pageSize: Int, nextHandler: PokemonCatcher) {
        self.pageSize = pageSize
        self.nextHandler = nextHandler
    }

    func first(completion: @escaping (Result<PokemonList, Error>) -> Void) {
        let results = database?.objects(DBPokemonList.self)

        guard let entityList = results?.first, !entityList.pokemons.isEmpty else {
            nextHandler.first(completion: completion)
            return
        }

        let firstPageEntities = entityList.pokemons.filter { [weak self] (pokemon: DBPokemon) -> Bool in
            guard let self = self else {
                return false
            }
            return pokemon.id >= 0 && pokemon.id < self.pageSize
        }

        let pokemons = firstPageEntities.compactMap { [weak self] (entity: DBPokemon) -> Pokemon? in
            self?.convert(entity)
        }

        guard !pokemons.isEmpty else {
            completion(Result.failure(DBError.firstPokemons))
            return
        }

        let list = PokemonList(totalPokemonCount: entityList.totalPokemonCount, pokemons: Array(pokemons))
        completion(Result.success(list))
    }

    private func convert(_ entity: DBPokemon) -> Pokemon {
        Pokemon(id: entity.id, name: entity.name, imageData: entity.imageData)
    }

    func next() {
    }

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
