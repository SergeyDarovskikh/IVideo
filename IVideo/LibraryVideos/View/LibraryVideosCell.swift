//
//  LibraryVideosCell.swift
//  IVideo
//
//  Created by Сергей Даровских on 17.02.2022.
//

import UIKit

class LibraryVideosCell: UITableViewCell {
    static var height: CGFloat = 94
    
    var url: URL? {
        didSet {
            guard let url = self.url else { return }
            self.titleLabel.text = url.lastPathComponent
            self.urlLabel.text = url.absoluteString
        }
    }
    
    var playButtonAction: (()->Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let urlLabelBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPink
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @objc func playButtonTapped() {
        playButtonAction?()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.isUserInteractionEnabled = true
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        self.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 18),
            containerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            containerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -18),
            containerView.heightAnchor.constraint(equalToConstant: 94)
        ])
        containerView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -8),
            titleLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
        containerView.addSubview(urlLabelBackgroundView)
        NSLayoutConstraint.activate([
            urlLabelBackgroundView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 0),
            urlLabelBackgroundView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            urlLabelBackgroundView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -65),
            urlLabelBackgroundView.heightAnchor.constraint(equalToConstant: 54)
        ])
        urlLabelBackgroundView.addSubview(urlLabel)
        NSLayoutConstraint.activate([
            urlLabel.leftAnchor.constraint(equalTo: urlLabelBackgroundView.leftAnchor, constant: 18),
            urlLabel.rightAnchor.constraint(equalTo: urlLabelBackgroundView.rightAnchor, constant: -18),
            urlLabel.centerYAnchor.constraint(equalTo: urlLabelBackgroundView.centerYAnchor)
        ])
        containerView.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.leftAnchor.constraint(equalTo: urlLabelBackgroundView.rightAnchor, constant: 7),
            playButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            playButton.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: 0),
            playButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}
