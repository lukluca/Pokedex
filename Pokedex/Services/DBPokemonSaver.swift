//
//  DBPokemonSaver.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import RealmSwift

class DBPokemonSaver {

    private let db: Realm?

    init(db: Realm?) {
        self.db = db
    }

    func save(totalPokemonCount: Int) {
        save(inside: db, totalPokemonCount: totalPokemonCount)
    }

    private func save(inside database: Realm?, totalPokemonCount: Int) {
        let pokedex = DBPokedex()
        pokedex.totalPokemonCount = totalPokemonCount
        try? writeInside(database: database, object: pokedex)
    }

    func save(pokemons: [Pokemon]) {
        save(inside: db, pokemons: pokemons)
    }

    private func save(inside database: Realm?, pokemons: [Pokemon]) {
        let dbPokemons = pokemons.map { pokemon -> DBPokemon in
            let pkm = DBPokemon()
            pkm.id = pokemon.id
            pkm.name = pokemon.name
            pkm.imageData = pokemon.imageData
            return pkm
        }
        try? writeInside(database: database, objects: dbPokemons)
    }

    private func writeInside(database: Realm?, object: Object) throws {
       try writeInside(database: database, objects: [object])
    }

    private func writeInside(database: Realm?, objects: [Object]) throws {
        try database?.write {
            database?.add(objects)
        }
    }
}
