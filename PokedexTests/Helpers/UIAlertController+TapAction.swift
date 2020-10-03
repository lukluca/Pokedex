//
//  PokemonCollectionViewControllerTests.swift
//  PokedexTests
//
//  Created by Luca Tagliabue on 3/10/2020.
//

import UIKit

extension UIAlertController {

    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tapButton(title: String) {
        guard let action = actions.first(where: {$0.title == title}),
              let block = action.value(forKey: "handler")
                else { return }
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(action)
    }
}
