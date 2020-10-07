//
//  DummyDataDownloader.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 7/10/2020.
//

import Foundation
@testable import Pokedex

struct DummyDataDownloader: DataDownloader {

    func download(from url: URL, completion: @escaping (Data?) -> Void) -> URLSessionDataTask {
        URLSessionDataTask()
    }
}
