//
//  ImageCollectionViewCell.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 06/10/2020.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {

    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }

    //Subviews
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    //Constraints
    private lazy var imageViewConstraints: [NSLayoutConstraint] = {
        [imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
         imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
         imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)]
    }()
    private var activatedConstraints = [NSLayoutConstraint]()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addCustomSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        addCustomSubviews()
    }

    private func addCustomSubviews() {
        contentView.addSubview(imageView)

        setNeedsUpdateConstraints()
    }

    override func updateConstraints() {
        defer {
            super.updateConstraints()
        }

        guard activatedConstraints.isEmpty else {
            return
        }

        NSLayoutConstraint.activate(imageViewConstraints)

        activatedConstraints = imageViewConstraints
    }

}
