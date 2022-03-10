//
//  VideoDownloader.swift
//  IVideo
//
//  Created by Сергей Даровских on 04.03.2022.
//

import Foundation
import UIKit
import AVFoundation

class VideoDownloader: NSObject {
    var streamLocationPath: String?
    var streamUrl: URL?
    var resultCompletion: ((DownloadResult)->())?
    
    func loadStreamVideo(url: URL) {
        if UserDefaultsManager.getVideoLocationPath(url: url) == nil {
            let urlAsset = AVURLAsset(url: url)
            self.streamUrl = url
            let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
            let preferredMediaSelection = urlAsset.preferredMediaSelection
            let assetDownloadURLSession = AVAssetDownloadURLSession(configuration: backgroundConfiguration,
                                                                    assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
            let assetTitle  = url.lastPathComponent
            
            guard let task =
                    assetDownloadURLSession.aggregateAssetDownloadTask(with: urlAsset,
                                                                       mediaSelections: [preferredMediaSelection],
                                                                       assetTitle: assetTitle,
                                                                       assetArtworkData: nil,
                                                                       options:
                                                                        [AVAssetDownloadTaskMinimumRequiredMediaBitrateKey: 265_000]) else { return }
            task.taskDescription = assetTitle
            
            task.resume()
        } else {
            self.resultCompletion?(.error("File already exists"))
        }
    }
    
    func loadClassicVideo(url: URL) {
        if UserDefaultsManager.getVideoLocationPath(url: url) == nil {
            let libraryUrl =  FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
            let destinationUrl = libraryUrl.appendingPathComponent(url.lastPathComponent)
            
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse, response.statusCode == 200, let data = data {
                        if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                            UserDefaultsManager.appendVideoUrl(url: url, locationPath: "Library/\(url.lastPathComponent)")
                            self.resultCompletion?(.success)
                        } else {
                            self.resultCompletion?(.error("Unable to save video"))
                        }
                    } else {
                        self.resultCompletion?(.error("Data error"))
                    }
                } else {
                    self.resultCompletion?(.error(error!.localizedDescription))
                }
            })
            task.resume()
        } else {
            self.resultCompletion?(.error("File already exists"))
        }
    }
}

extension VideoDownloader: AVAssetDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.resultCompletion?(.error("Video URL is wrong"))
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    willDownloadTo location: URL) {
        self.streamLocationPath = location.relativePath
    }
    
    func urlSession(_ session: URLSession, aggregateAssetDownloadTask: AVAggregateAssetDownloadTask,
                    didCompleteFor mediaSelection: AVMediaSelection) {
        if let locationPath = streamLocationPath, let streamUrl = self.streamUrl {
            self.resultCompletion?(.success)
            UserDefaultsManager.appendVideoUrl(url: streamUrl, locationPath: locationPath)
        } else {
            self.resultCompletion?(.error("Error with saving video location"))
        }
    }
}

enum DownloadResult {
    case success
    case error(String)
}
