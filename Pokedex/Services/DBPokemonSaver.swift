//
//  DBPokemonSaver.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import RealmSwift

class DBPokemonSaver {

    private var database: Realm? {
        try? Realm()
    }

    func save(totalPokemonCount: Int) {
        let pokedex = DBPokedex()
        pokedex.totalPokemonCount = totalPokemonCount
        try? writeInsideDatabase(object: pokedex)
    }

    func save(pokemons: [Pokemon]) {
        let list: DBPokemonList
        if let oldList = readPokemonsList() {
            list = oldList
        } else {
            list = DBPokemonList()
        }
        let dbPokemons = pokemons.map { pokemon -> DBPokemon in
            let pkm = DBPokemon()
            pkm.id = pokemon.id
            pkm.name = pokemon.name
            pkm.imageData = pokemon.imageData
            return pkm
        }
        list.pokemons.append(objectsIn: dbPokemons)
        try? writeInsideDatabase(object: list)
    }

    private func writeInsideDatabase(object: Object) throws {
        try database?.write {
            database?.add(object)
        }
    }

    private func readPokemonsList() -> DBPokemonList? {
        database?.objects(DBPokemonList.self).first
    }
}
