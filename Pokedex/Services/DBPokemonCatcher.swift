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

    func first(completion: @escaping (Result<[Pokemon], Error>) -> Void) {

        let results = database?.objects(DBPokemon.self).filter("id >= 0 AND id < \(pageSize)")

        guard let entities = results, entities.count > 0 else {
            nextHandler.first(completion: completion)
            return
        }

        let pokemons = entities.compactMap { [weak self] (entity: DBPokemon) -> Pokemon? in
            self?.convert(entity)
        }

        guard !pokemons.isEmpty else {
            completion(Result.failure(DBError.firstPokemons))
            return
        }

        completion(Result.success(Array(pokemons)))
    }

    private func convert(_ entity: DBPokemon) -> Pokemon? {
        guard let image = UIImage(data: entity.imageData) else {
            return nil
        }
        return Pokemon(id: entity.id, name: entity.name, image: image)
    }

    func next() {
    }

    func taskOngoingFor(for index: Int) -> Bool {
        false
    }
}
