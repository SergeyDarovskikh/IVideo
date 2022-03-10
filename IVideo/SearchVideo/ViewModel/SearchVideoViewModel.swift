//
//  SearchVideoViewModel.swift
//  IVideo
//
//  Created by Сергей Даровских on 08.03.2022.
//

import Foundation
import UIKit
import AVFoundation

class SearchVideoViewModel {
    func searchButtonTapped(url: String) -> SearchResult {
        let text = url.removingWhitespaces()
        if text.isValidURL {
            guard let url = URL(string: text) else { return .error("Wrong URL") }
            return .success(url)
        } else {
            return .error("Wrong URL")
        }
    }
    
    func downloadButtonTapped(url: String?, resultCompletion: @escaping (DownloadResult) -> ()) {
        guard let url = url, url != "" else { resultCompletion(.error("URL field is empty")); return }
        
        let downloader = VideoDownloader()
        downloader.resultCompletion = { result in
            switch result {
            case .success:
                resultCompletion(.success)
            case .error(let error):
                resultCompletion(.error(error))
            }
        }
        
        let text = url.removingWhitespaces()
        
        if text.isValidURL {
            guard let url = URL(string: text) else { resultCompletion(.error("Wrong URL")); return }
            if text.contains(".m3u8") {
                downloader.loadStreamVideo(url: url)
            } else {
                downloader.loadClassicVideo(url: url)
            }
        } else {
            resultCompletion(.error("Wrong URL"))
        }
    }
    
    enum SearchResult {
        case success(URL)
        case error(String)
    }
}


