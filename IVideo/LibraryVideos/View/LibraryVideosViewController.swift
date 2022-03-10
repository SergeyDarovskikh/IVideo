//
//  LibraryVideosViewController.swift
//  IVideo
//
//  Created by Сергей Даровских on 17.02.2022.
//

import UIKit
import AVFoundation

class LibraryVideosViewController: UIViewController {
    private let viewModel = LibraryVideosViewModel()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.register(LibraryVideosCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let imageAlert: ImageAlert = {
        return ImageAlert(systemName: "questionmark.video", message: "You haven't downloaded any videos yet")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDelegates()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Library"
    }
    
    private func setupDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func playButtonTapped(videoUrl: URL) {
        let videoPlayerView = VideoPlayerViewController(videoUrl: videoUrl)
        videoPlayerView.modalPresentationStyle = .fullScreen
        self.present(videoPlayerView, animated: true)
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateData()
    }
    
    func updateData() {
        viewModel.setup()
        tableView.reloadData()
        if viewModel.cellsUrlsArray.isEmpty {
            showImageAlert()
        } else {
            removeImageAlert()
        }
    }
    
    func showImageAlert() {
        DispatchQueue.main.async {
            self.view.addSubview(self.imageAlert)
            NSLayoutConstraint.activate([
                self.imageAlert.leftAnchor.constraint(equalTo: self.tableView.leftAnchor, constant: 0),
                self.imageAlert.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0),
                self.imageAlert.rightAnchor.constraint(equalTo: self.tableView.rightAnchor, constant: 0),
                self.imageAlert.bottomAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 0)
            ])
        }
    }
    
    func removeImageAlert() {
        DispatchQueue.main.async {
            self.imageAlert.removeFromSuperview()
        }
    }
}

extension LibraryVideosViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.getHeightForRow(forIndexPath: indexPath)
    }
}

extension LibraryVideosViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getNumberOfRowsInSections()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LibraryVideosCell
        let url = viewModel.getUrlForCell(atIndexPath: indexPath)
        cell.url = url
        
        cell.contentView.isUserInteractionEnabled = false
        cell.playButtonAction =  { self.playButtonTapped(videoUrl: url!) }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (_, _, completionHandler) in
            self.deleteRow(indexPath: indexPath)
            completionHandler(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func deleteRow(indexPath: IndexPath) {
        guard let videoUrl = self.viewModel.getUrlForCell(atIndexPath: indexPath) else {return}
        
        if let deleteError = self.viewModel.removeVideo(url: videoUrl) {
            self.showDefaultAlert(title: "ERROR", message: deleteError.localizedDescription)
        }
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        if self.viewModel.cellsUrlsArray.isEmpty {
            self.showImageAlert()
        } else {
            self.removeImageAlert()
        }
    }
}
