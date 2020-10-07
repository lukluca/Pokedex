//
//  DetailCellViewModel.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 6/10/2020.
//

import UIKit

class DetailViewModel {
    let title: String
    private var collection = [DetailCellViewModel]()
    private let sprites: Sprites

    init(title: String, sprites: Sprites) {
        self.title = title
        self.sprites = sprites
    }

    func numberOfItems(in section: Int) -> Int {
        collection.count
    }

    func item(at indexPath: IndexPath) -> DetailCellViewModel {
        collection[indexPath.item]
    }

    func startLoadImages() {
        appendIfPresent(convert(sprites.frontDefault))
        appendIfPresent(convert(sprites.frontShiny))
        appendIfPresent(convert(sprites.frontFemale))
        appendIfPresent(convert(sprites.frontShinyFemale))
        appendIfPresent(convert(sprites.backDefault))
        appendIfPresent(convert(sprites.backShiny))
        appendIfPresent(convert(sprites.backFemale))
        appendIfPresent(convert(sprites.backShinyFemale))

        //Todo check if no data, download
        //everytime i have a data, deliver info to vc
    }

    private func convert(_ item: DefaultImage) -> DetailCellViewModel? {
        guard let image = UIImage(data: item.data) else {
            return nil
        }
        return DetailCellViewModel(image: image)
    }

    private func convert(_ item: Image?) -> DetailCellViewModel? {
        guard let data = item?.data else {
            return nil
        }
        guard let image = UIImage(data: data) else {
            return nil
        }
        return DetailCellViewModel(image: image)
    }

    private func appendIfPresent(_ cellViewModel: DetailCellViewModel?) {
        if let model = cellViewModel {
            collection.append(model)
        }
    }
}
