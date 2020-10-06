//
//  DetailViewController.swift
//  Pokedex
//
//  Created by Luca Tagliabue on 06/10/2020.
//

import UIKit

class DetailViewController: UIViewController {

    private let viewModel: DetailViewModel

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
        
        if #available(iOS 13, *) {
        } else {
            addCloseButton()
        }

        addTitleLabel()
    }

    private func addCloseButton() {
        let closeButton = UIButton()
        let image = UIImage(named: "close")
        closeButton.setImage(image, for: .normal)
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchUpInside)

        view.addSubview(closeButton)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
                           closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                           closeButton.heightAnchor.constraint(equalToConstant: 44),
                           closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)]
        NSLayoutConstraint.activate(constraints)
    }

    private func addTitleLabel() {
        let label = UILabel()
        label.text = viewModel.title
        view.addSubview(label)

        label.textAlignment = .center

        label.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [label.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
                           label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
                           label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)]
        NSLayoutConstraint.activate(constraints)
    }

    @objc func closeAction(sender: UIButton) {
        dismiss(animated: true)
    }
}
