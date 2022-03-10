//
//  SearchVideoViewController.swift
//  IVideo
//
//  Created by Сергей Даровских on 17.02.2022.
//

import UIKit
import AVFoundation

class SearchVideoViewController: UIViewController {
    
    var viewModel = SearchVideoViewModel()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.text = "URL"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let urlTextFild: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = .systemGray6
        textField.returnKeyType = UIReturnKeyType.done
        textField.keyboardType = .emailAddress
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPink
        button.setTitle("Play Video", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemPink
        button.setTitle("Download Video", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        button.tintColor = .white
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        setupDelegates()
        setupNavigationBar()
        (UIApplication.shared.delegate as! AppDelegate).restrictRotation = .portrait
    }
    
    private func setupViews() {
        view.backgroundColor = .white
    }
    
    private func setupDelegates() {
        urlTextFild.delegate = self
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Search Video"
    }
    
    @objc private func playButtonTapped() {
        let searchResult = viewModel.searchButtonTapped(url: urlTextFild.text ?? "")
        switch searchResult {
        case .success(let url):
            let videoPlayerView = VideoPlayerViewController(videoUrl: url)
            videoPlayerView.modalPresentationStyle = .fullScreen
            self.present(videoPlayerView, animated: true)
        case .error(let error):
            showDefaultAlert(title: "ERROR", message: error)
        }
    }
    
    @objc private func downloadButtonTapped() {
        downloadButton.loadingIndicator(true)
        viewModel.downloadButtonTapped(url: urlTextFild.text, resultCompletion: { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.downloadButton.loadingIndicator(false)
                    self.showDefaultAlert(title: "Congratulations", message: "Video has been downloaded", actionCompletion:  { _ in
                        if let tabBarTabs = self.tabBarController?.viewControllers,
                           let libraryTabNavigationController = tabBarTabs[1] as? UINavigationController,
                           let libraryVC = libraryTabNavigationController.viewControllers[0] as? LibraryVideosViewController {
                            libraryVC.updateData()
                        }
                    })
                }
            case .error(let error):
                DispatchQueue.main.async {
                    self.downloadButton.loadingIndicator(false)
                    self.showDefaultAlert(title: "ERROR", message: error)
                }
            }
        })
    }
    
    private func setupConstraints() {
        view.addSubview(urlLabel)
        NSLayoutConstraint.activate([
            urlLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 165),
            urlLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 26)
        ])
        view.addSubview(urlTextFild)
        NSLayoutConstraint.activate([
            urlTextFild.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 10),
            urlTextFild.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 18),
            urlTextFild.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -18),
            urlTextFild.heightAnchor.constraint(equalToConstant: 54)
        ])
        view.addSubview(playButton)
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: urlTextFild.bottomAnchor, constant: 30),
            playButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 46),
            playButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -46),
            playButton.heightAnchor.constraint(equalToConstant: 54)
        ])
        view.addSubview(downloadButton)
        NSLayoutConstraint.activate([
            downloadButton.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            downloadButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 46),
            downloadButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -46),
            downloadButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
}

extension SearchVideoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


