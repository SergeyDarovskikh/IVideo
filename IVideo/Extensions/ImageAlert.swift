//
//  ImageAlert.swift
//  IVideo
//
//  Created by Сергей Даровских on 08.03.2022.
//

import UIKit

class ImageAlert: UIView {
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGray4
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .systemGray4
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(systemName: String, message: String) {
        super.init(frame: UIScreen.main.bounds)
        self.imageView.image = UIImage(systemName: systemName)
        self.label.text = message
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            imageView.widthAnchor.constraint(equalToConstant: 60)
        ])
        self.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
            label.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
