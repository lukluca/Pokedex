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
    @objc dynamic var sprites: DBSprites! = DBSprites()
    @objc dynamic var details: DBDetails! = DBDetails()

    override static func primaryKey() -> String? {
        "id"
    }
}

class DBSprites: Object {
    @objc dynamic var frontDefault: DBDefaultImage! = DBDefaultImage()
    @objc dynamic var frontShiny: DBImage?
    @objc dynamic var frontFemale: DBImage?
    @objc dynamic var frontShinyFemale: DBImage?
    @objc dynamic var backDefault: DBImage?
    @objc dynamic var backShiny: DBImage?
    @objc dynamic var backFemale: DBImage?
    @objc dynamic var backShinyFemale: DBImage?
}

class DBImage: Object {
    @objc dynamic var data: Data?
    @objc dynamic var url: String = ""
}

class DBDefaultImage: Object {
    @objc dynamic var data = Data()
}

class DBPokedex: Object {
    @objc dynamic var totalPokemonCount = 0
}

class DBDetails: Object {
    @objc dynamic var baseExperience: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var weight: Int = 0
}