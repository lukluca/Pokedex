//
//  DBPokemonUpdater.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 7/10/2020.
//

import RealmSwift

class DBPokemonUpdater {

    lazy var pokemon: DBPokemon? = {
        db?.object(ofType: DBPokemon.self, forPrimaryKey: id)
    }()

    private let db: Realm?
    private let id: Int

    init(db: Realm?, id: Int) {
        self.db = db
        self.id = id
    }

    func update(type: SpritesType, with data: Data) {
        try? db?.write {
            let pok = pokemon
            switch type {
            case .frontShiny:
                pok?.sprites.frontShiny?.data = data
            case .frontFemale:
                pok?.sprites.frontFemale?.data = data
            case .frontShinyFemale:
                pok?.sprites.frontShinyFemale?.data = data
            case .backDefault:
                pok?.sprites.backDefault?.data = data
            case .backShiny:
                pok?.sprites.backShiny?.data = data
            case .backFemale:
                pok?.sprites.backFemale?.data = data
            case .backShinyFemale:
                pok?.sprites.backShinyFemale?.data = data
            }
        }
    }
}
