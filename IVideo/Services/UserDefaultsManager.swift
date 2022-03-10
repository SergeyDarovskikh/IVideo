//
//  UserDefaultsManager.swift
//  IVideo
//
//  Created by Сергей Даровских on 03.03.2022.
//
import Foundation

class UserDefaultsManager {
    static let userDefaults = UserDefaults.standard
    
    static func appendVideoUrl(url: URL, locationPath: String) {
        var videoUrls = getVideoUrls()
        videoUrls.append(url)
        let videoUrlsStrings = videoUrls.map({ $0.absoluteString })
        userDefaults.set(videoUrlsStrings, forKey: "VideoUrls")
        userDefaults.set(locationPath, forKey: url.absoluteString)
    }
    
    static func getVideoLocationPath(url: URL) -> String? {
        return userDefaults.string(forKey: url.absoluteString)
    }
    
    static func removeVideo(url: URL) {
        var videoUrls = getVideoUrls()
        if let i = videoUrls.firstIndex(of: url) {
            videoUrls.remove(at: i)
        }
        let videoUrlsStrings = videoUrls.map({ $0.absoluteString })
        userDefaults.set(videoUrlsStrings, forKey: "VideoUrls")
        userDefaults.removeObject(forKey: url.absoluteString)
    }

    static func getVideoUrls() -> [URL] {
        guard let stringArray = userDefaults.stringArray(forKey: "VideoUrls") else { return [] }
        return stringArray.map { URL(string: $0)! }
    }
}
