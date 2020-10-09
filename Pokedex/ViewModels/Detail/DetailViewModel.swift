//
//  DetailCellViewModel.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import UIKit

class DetailViewModel {
    private let _number: String
    var number: String {
        get {
            "Number: \(_number)"
        }
    }
    let title: String
    private let _baseExperience: String
    var baseExperience: String {
        get {
            "Base Experience: \(_baseExperience)"
        }
    }
    private let _height: String
    var height: String {
        get {
            "Height: \(_height)"
        }
    }
    private let _weight: String
    var weight: String {
        get {
            "Weight: \(_weight)"
        }
    }
    private let sprites: Sprites

    private let loader: SpritesLoader

    private var collection = [DetailCellViewModel]()

    init(number: String,
         title: String,
         baseExperience: String,
         height: String,
         weight: String,
         sprites: Sprites,
         loader: SpritesLoader) {
        self._number = number
        self.title = title
        self._baseExperience = baseExperience
        self._height = height
        self._weight = weight
        self.sprites = sprites
        self.loader = loader
    }

    var onItemAdded: ((IndexPath) -> ())?

    func numberOfItems(in section: Int) -> Int {
        collection.count
    }

    func item(at indexPath: IndexPath) -> DetailCellViewModel {
        collection[indexPath.item]
    }

    func startLoadImages() {

        loader.onDataLoad = { [weak self] data in
            guard let self = self else {
                return
            }

            let appended = self.appendedIfPresent(self.convert(data))

            guard appended else {
                return
            }

            let item = self.collection.count - 1

            self.onItemAdded?(IndexPath(item: item, section: 0))
        }

        appendedIfPresent(convert(sprites.frontDefault))

        if !appendedIfPresent(convert(sprites.frontShiny)) {
            loader.loadIfNeeded(sprites: sprites, of: .frontShiny)
        }
        if !appendedIfPresent(convert(sprites.frontFemale)) {
            loader.loadIfNeeded(sprites: sprites, of: .frontFemale)
        }
        if !appendedIfPresent(convert(sprites.frontShinyFemale)) {
            loader.loadIfNeeded(sprites: sprites, of: .frontShinyFemale)
        }
        if !appendedIfPresent(convert(sprites.backDefault)) {
            loader.loadIfNeeded(sprites: sprites, of: .backDefault)
        }
        if !appendedIfPresent(convert(sprites.backShiny)) {
            loader.loadIfNeeded(sprites: sprites, of: .backShiny)
        }
        if !appendedIfPresent(convert(sprites.backFemale)) {
            loader.loadIfNeeded(sprites: sprites, of: .backFemale)
        }
        if !appendedIfPresent(convert(sprites.backShinyFemale)) {
            loader.loadIfNeeded(sprites: sprites, of: .backShinyFemale)
        }
    }

    func stopLoadImages() {
        loader.onDataLoad = nil
        loader.stopLoad()
    }

    private func convert(_ item: DefaultImage) -> DetailCellViewModel? {
        guard let image = UIImage(data: item.data) else {
            return nil
        }
        return DetailCellViewModel(image: image)
    }

    private func convert(_ item: Image?) -> DetailCellViewModel? {
        convert(item?.data)
    }

    private func convert(_ data: Data?) -> DetailCellViewModel? {
        guard let data = data else {
            return nil
        }
        guard let image = UIImage(data: data) else {
            return nil
        }
        return DetailCellViewModel(image: image)
    }

    @discardableResult
    private func appendedIfPresent(_ cellViewModel: DetailCellViewModel?) -> Bool {
        guard let model = cellViewModel else {
            return false
        }

        collection.append(model)
        return true
    }
}
