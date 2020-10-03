// See LICENSE.txt for licensing information

import UIKit

enum UIImageError: Error {
    case failureWhileMake
}

extension UIImage {

    static func imageResource(insideBundleOf clazz: AnyClass) throws -> UIImage {
        guard let path = Bundle(for: clazz).path(forResource: nil, ofType: "png") else {
            throw UIImageError.failureWhileMake
        }

        guard let image = UIImage(contentsOfFile: path) else {
            throw UIImageError.failureWhileMake
        }

        return image
    }

    static func imageResourceAsData(insideBundleOf clazz: AnyClass) throws -> Data {
        let image = try self.imageResource(insideBundleOf: clazz)

        guard let data = image.pngData() else {
            throw UIImageError.failureWhileMake
        }

        return data
    }
}


