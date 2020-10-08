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

    func loadIfNeeded(sprites: Sprites, of type: SpritesType) {

        switch type {
        case .frontShiny:
            downloadIfNeeded(sprites.frontShiny, for: type)
        case .frontFemale:
            downloadIfNeeded(sprites.frontFemale, for: type)
        case .frontShinyFemale:
            downloadIfNeeded(sprites.frontShinyFemale, for: type)
        case .backDefault:
            downloadIfNeeded(sprites.backDefault, for: type)
        case .backShiny:
            downloadIfNeeded(sprites.backShiny, for: type)
        case .backFemale:
            downloadIfNeeded(sprites.backFemale, for: type)
        case .backShinyFemale:
            downloadIfNeeded(sprites.backShinyFemale, for: type)
        }
    }

    private func downloadIfNeeded(_ image: Image?, for type: SpritesType) {
        guard let img = image else {
            return
        }

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
