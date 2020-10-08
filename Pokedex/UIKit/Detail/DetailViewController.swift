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
        addScrollView(scroll, below: label)
        let collection = makeCollectionView()
        addCollectionView(collection, inside: scroll)
        configureCollectionView(collection)

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
        let label = UILabel()
        label.textAlignment = .center
        label.text = viewModel.title
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

    private func addScrollView(_ scroll: UIScrollView, below otherView: UIView) {
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

    private func addCollectionView(_ collection: UICollectionView, inside scroll: UIScrollView) {
        scroll.addSubview(collection)

        collection.translatesAutoresizingMaskIntoConstraints = false
        let guide = view.safeAreaLayoutGuide
        let constraints = [collection.topAnchor.constraint(equalTo: scroll.topAnchor),
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
