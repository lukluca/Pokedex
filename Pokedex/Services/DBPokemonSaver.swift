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
            convert(pokemon)
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

    private func convert(_ resource: Pokemon) -> DBPokemon {
        let pkm = DBPokemon()
        pkm.id = resource.id
        pkm.name = resource.name
        pkm.sprites = convert(resource.sprites)
        return pkm
    }

    private func convert(_ resource: Sprites) -> DBSprites {
        let spr = DBSprites()
        spr.frontDefault = convert(resource.frontDefault)
        spr.frontShiny = convert(resource.frontShiny)
        spr.frontFemale = convert(resource.frontFemale)
        spr.frontShinyFemale = convert(resource.frontShinyFemale)
        spr.backDefault = convert(resource.backDefault)
        spr.backShiny = convert(resource.backShiny)
        spr.backFemale = convert(resource.backFemale)
        spr.backShinyFemale = convert(resource.backShinyFemale)
        return spr
    }

    private func convert(_ resource: DefaultImage) -> DBDefaultImage {
        let image = DBDefaultImage()
        image.data = resource.data
        return image
    }

    private func convert(_ resource: Image?) -> DBImage? {
        guard let res = resource else {
            return nil
        }
        let image = DBImage()
        image.data = res.data
        image.url = res.url.absoluteString
        return image
    }
}
