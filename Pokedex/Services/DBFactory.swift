//
//  DBFactory.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 5/10/2020.
//

import RealmSwift

struct DBFactory {

    func make() -> Realm? {
        guard let dbUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("pokedex.realm")
                else {
            return  nil
        }
        return try? Realm(fileURL: dbUrl)
    }
}
