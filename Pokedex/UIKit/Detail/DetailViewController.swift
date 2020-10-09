//
//  DetailViewController.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 06/10/2020.
//

import UIKit

class DetailViewController: UIViewController {

    private let viewModel: DetailViewModel

    private let cellReuseIdentifier = "ImageCell"

    private var collectionView: UICollectionView?

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Please use init with viewModel instead")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        addCustomSubviews()

        viewModel.startLoadImages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.onItemAdded = { [weak self] path in
            self?.collectionView?.insertItems(at: [path])
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel.onItemAdded = nil
        viewModel.stopLoadImages()
    }

    private func addCustomSubviews() {
        addCloseButton()

        let label = makeTitleLabel()
        addTitleLabel(label)

        let scroll = UIScrollView()
        let scrollContent = DetailsContentView()
        
        addScrollView(scroll, contentView: scrollContent, below: label)

        let collection = makeCollectionView()
        addCollectionView(collection, inside: scrollContent)
        configureCollectionView(collection)

        addStackView(inside: scrollContent, below: collection)

        self.collectionView = collection
    }

    private func addCloseButton() {
        let closeButton = UIButton()
        let image = UIImage(named: "close")
        closeButton.setImage(image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)

        view.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        let constraints = [closeButton.topAnchor.constraint(equalTo: guide.topAnchor, constant: .margin),
                           closeButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20),
                           closeButton.heightAnchor.constraint(equalToConstant: 44),
                           closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)]
        NSLayoutConstraint.activate(constraints)
    }

    private func makeTitleLabel() -> UILabel {
        let label = makeLabel(with: viewModel.title)
        label.textAlignment = .center
        return label
    }

    private func addTitleLabel(_ label: UILabel) {
        view.addSubview(label)

        label.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        let constraints = [label.topAnchor.constraint(equalTo: guide.topAnchor, constant: 80),
                           label.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: .margin),
                           label.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -.margin)]
        NSLayoutConstraint.activate(constraints)
    }

    private func addScrollView(_ scroll: UIScrollView, contentView: UIView, below otherView: UIView) {
        scroll.addSubview(contentView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        let contentGuide = scroll.contentLayoutGuide
        let contentConstraints = [contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
                                  contentView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
                                  contentView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
                                  contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor)]
        NSLayoutConstraint.activate(contentConstraints)

        view.addSubview(scroll)

        scroll.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        let constraints = [scroll.topAnchor.constraint(equalTo: otherView.bottomAnchor, constant: .margin),
                           scroll.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: .margin),
                           scroll.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -.margin),
                           scroll.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: .margin)]
        NSLayoutConstraint.activate(constraints)
    }

    private func makeCollectionView() -> UICollectionView {
        let layout = DetailCollectionViewFlowLayout()
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }

    private func addCollectionView(_ collection: UICollectionView, inside container: UIView) {
        container.addSubview(collection)

        collection.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        let constraints = [collection.topAnchor.constraint(equalTo: container.topAnchor),
                           collection.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: .margin),
                           collection.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -.margin),
                           collection.heightAnchor.constraint(equalToConstant: 200)]
        NSLayoutConstraint.activate(constraints)
    }

    private func configureCollectionView(_ collection: UICollectionView) {
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.contentInsetAdjustmentBehavior = .always
        collection.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    private func addStackView(inside container: UIView, below otherView: UIView) {
        let stack = UIStackView()

        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center

        let numberLabel = makeLabel(with: viewModel.number)
        let baseExperienceLabel = makeLabel(with: viewModel.baseExperience)
        let heightLabel = makeLabel(with: viewModel.height)
        let weightLabel = makeLabel(with: viewModel.weight)

        stack.addArrangedSubview(numberLabel)
        stack.addArrangedSubview(baseExperienceLabel)
        stack.addArrangedSubview(heightLabel)
        stack.addArrangedSubview(weightLabel)

        container.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        let constraints = [stack.topAnchor.constraint(equalTo: otherView.bottomAnchor, constant: .margin),
                           stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: .margin),
                           stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -.margin),
                           stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: .margin)]
        NSLayoutConstraint.activate(constraints)
    }

    private func makeLabel(with text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        return label
    }

    @objc func closeAction(sender: UIButton) {
        dismiss(animated: true)
    }
}

extension DetailViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems(in: section)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)

        guard let imageCell = cell as? ImageCollectionViewCell else {
            return cell
        }

        let cellViewModel = viewModel.item(at: indexPath)
        imageCell.image = cellViewModel.image
        return imageCell
    }
}

private extension CGFloat {
    static let margin: CGFloat = 30
}

private class DetailsContentView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let collection = subviews.first { $0 is UICollectionView }
        
        guard let collectionView = collection else {
            return super.point(inside: point, with: event)
        }
        
        let converted = self.convert(point, to: collectionView)
        let touchedCollection = collectionView.hitTest(converted, with: event) != nil
        
        if touchedCollection {
            return true
        }

        return super.point(inside: point, with: event)
    }
}

