//
//  SpritesDownloader.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 8/10/2020.
//

import Foundation

class SpritesDownloader: SpritesLoader {

    var onDataLoad: ((Data) -> ())?

    private let nextHandler: DBPokemonUpdater
    private let dataDownloader: DataDownloader

    private var tasks = [URLSessionTask]()

    init(dataDownloader: DataDownloader, nextHandler: DBPokemonUpdater) {
        self.dataDownloader = dataDownloader
        self.nextHandler = nextHandler
    }

    func loadIfNeeded(sprites: Sprites) {
        downloadIfNeeded(sprites.frontShiny, for: .frontShiny)
        downloadIfNeeded(sprites.frontFemale, for: .frontFemale)
        downloadIfNeeded(sprites.frontShinyFemale, for: .frontShinyFemale)
        downloadIfNeeded(sprites.backDefault, for: .backDefault)
        downloadIfNeeded(sprites.backShiny, for: .backShiny)
        downloadIfNeeded(sprites.backFemale, for: .backFemale)
        downloadIfNeeded(sprites.backShinyFemale, for: .backShinyFemale)
    }

    private func downloadIfNeeded(_ image: Image?, for type: SpritesType) {

        let dbSprites = nextHandler.pokemon?.sprites

        switch type {
        case .frontShiny:
            if let data = dbSprites?.frontShiny?.data {
                self.onDataLoad?(data)
                return
            }

        case .frontFemale:
            if let data = dbSprites?.frontFemale?.data {
                self.onDataLoad?(data)
                return
            }
        case .frontShinyFemale:
            if let data = dbSprites?.frontShinyFemale?.data {
                self.onDataLoad?(data)
                return
            }
        case .backDefault:
            if let data = dbSprites?.backDefault?.data {
                self.onDataLoad?(data)
                return
            }
        case .backShiny:
            if let data = dbSprites?.backShiny?.data {
                self.onDataLoad?(data)
                return
            }
        case .backFemale:
            if let data = dbSprites?.backFemale?.data {
                self.onDataLoad?(data)
                return
            }

        case .backShinyFemale:
            if let data = dbSprites?.backShinyFemale?.data {
                self.onDataLoad?(data)
                return
            }
        }

        guard let img = image else {
            return
        }
        guard img.data == nil else {
            return
        }

        let task = dataDownloader.download(from: img.url) { [weak self] data in
            guard let self = self else {
                return
            }

            guard let dt = data else {
                return
            }

            DispatchQueue.main.async {
                self.nextHandler.update(type: type, with: dt)
                self.onDataLoad?(dt)
            }
        }

        tasks.append(task)
    }

    func stopLoad() {
        guard !tasks.isEmpty else {
            return
        }
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
    }
}
