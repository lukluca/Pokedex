//
//  DataDownloader.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 07/10/2020.
//
//

import Foundation

protocol DataDownloader {
    func download(from url: URL, completion: @escaping (Data?) -> Void) -> URLSessionDataTask
}
