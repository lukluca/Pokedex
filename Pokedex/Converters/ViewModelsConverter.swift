//
//  ViewModelsConverter.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import UIKit

struct ViewModelsConverter {

    func convertIntoCellViewModels(_ pokemons: [Pokemon]) -> [CellViewModel] {
        pokemons.compactMap {self.convertIntoCellViewModel($0)}
    }

    private func convertIntoCellViewModel(_ pokemon: Pokemon) -> CellViewModel? {
        guard let image = UIImage(data: pokemon.sprites.frontDefault.data) else {
            return nil
        }
        return CellViewModel(id: pokemon.id, text: pokemon.name.firstUppercase, image: image)
    }
}

private extension StringProtocol {
    var firstUppercase: String { prefix(1).uppercased() + dropFirst() }
}
