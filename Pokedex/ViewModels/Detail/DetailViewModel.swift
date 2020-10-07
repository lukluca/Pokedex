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
    private let downloader: DataDownloader
    private var tasks = [URLSessionTask]()

    init(title: String, sprites: Sprites, downloader: DataDownloader) {
        self.title = title
        self.sprites = sprites
        self.downloader = downloader
    }

    var onItemAdded: ((IndexPath) -> ())?

    func numberOfItems(in section: Int) -> Int {
        collection.count
    }

    func item(at indexPath: IndexPath) -> DetailCellViewModel {
        collection[indexPath.item]
    }

    func startLoadImages() {
        appendedIfPresent(convert(sprites.frontDefault))
        appendedIfPresent(convert(sprites.frontShiny))
        appendedIfPresent(convert(sprites.frontFemale))
        appendedIfPresent(convert(sprites.frontShinyFemale))
        appendedIfPresent(convert(sprites.backDefault))
        appendedIfPresent(convert(sprites.backShiny))
        appendedIfPresent(convert(sprites.backFemale))
        appendedIfPresent(convert(sprites.backShinyFemale))

        downloadIfNeeded(sprites.frontShiny)
        downloadIfNeeded(sprites.frontFemale)
        downloadIfNeeded(sprites.frontShinyFemale)
        downloadIfNeeded(sprites.backDefault)
        downloadIfNeeded(sprites.backShiny)
        downloadIfNeeded(sprites.backFemale)
        downloadIfNeeded(sprites.backShinyFemale)
    }

    func stopLoadImages() {
        guard !tasks.isEmpty else {
            return
        }
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
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

    private func downloadIfNeeded(_ image: Image?) {
        guard let img = image else {
            return
        }
        guard img.data == nil else {
            return
        }

        let task = downloader.download(from: img.url) { [weak self] data in
            guard let self = self else {
                return
            }

            let appended = self.appendedIfPresent(self.convert(data))

            guard appended else {
                return
            }

            DispatchQueue.main.async {
                self.onItemAdded?(IndexPath(item: (self.collection.count - 1), section: 0))
            }
        }

        tasks.append(task)
    }
}
