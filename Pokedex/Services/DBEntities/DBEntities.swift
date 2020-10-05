// See LICENSE.txt for licensing information

//
//  DBEntities.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import RealmSwift

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
