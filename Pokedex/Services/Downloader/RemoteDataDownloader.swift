//
//  RemoteDataDownloader.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 07/10/2020.
//
//

import Foundation

class RemoteDataDownloader: DataDownloader {

    private let session: URLSession

    init(session: URLSession) {
        self.session = session
    }

    func download(from url: URL, completion: @escaping (Data?) -> Void) -> URLSessionDataTask {
        let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) -> () in
            completion(data)
        }
        task.resume()

        return task
    }
}
