//
//  PokemonCollectionViewCell.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 1/10/2020.
//

import UIKit

class PokemonCollectionViewCell: UICollectionViewCell {
    
    private let padding: CGFloat = 15
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var image: UIImage? {
        didSet {
            guard let image = image else {
                imageView.image = nil
                startAnimateIfNeeded()
                return
            }
            stopAnimate()
            imageView.image = image
        }
    }
    
    //Subviews
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.accessibilityIdentifier = "imageView"
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.accessibilityIdentifier = "nameLabel"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        return view
    }()
    
    //Constraints
    private lazy var imageViewConstraints: [NSLayoutConstraint] = {
        [imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)]
    }()
    private lazy var nameLabelConstraints: [NSLayoutConstraint] = {
        [nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
         nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding),
         nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
         nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding)]
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

    func startAnimateIfNeeded() {
        guard imageView.image == nil else {
            return
        }

        imageView.backgroundColor = .systemPink
        let pulseAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 3
        pulseAnimation.fromValue = 0.3
        pulseAnimation.toValue = 0.7
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        imageView.layer.add(pulseAnimation, forKey: "pulse")
    }

    func stopAnimate() {
        imageView.layer.removeAllAnimations()
        imageView.backgroundColor = nil
    }
    
    private func addCustomSubviews() {
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        defer {
            super.updateConstraints()
        }
        
        guard activatedConstraints.isEmpty else {
            return
        }
        
        let constraints = imageViewConstraints + nameLabelConstraints
        
        NSLayoutConstraint.activate(constraints)
        
        activatedConstraints = constraints
    }
}
