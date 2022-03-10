//
//  LibraryVideosViewModel.swift
//  IVideo
//
//  Created by Сергей Даровских on 17.02.2022.
//

import UIKit

class LibraryVideosViewModel {
    var cellsUrlsArray = [URL]()
    
    init() {
        cellsUrlsArray = UserDefaultsManager.getVideoUrls()
    }
    
    func setup() {
        cellsUrlsArray = UserDefaultsManager.getVideoUrls()
    }
    
    func getHeightForRow(forIndexPath indexPath: IndexPath) -> CGFloat {
        return LibraryVideosCell.height
    }
    
    func getNumberOfRowsInSections() -> Int {
        return cellsUrlsArray.count
    }
    
    func getUrlForCell(atIndexPath indexPath: IndexPath) -> URL? {
        return cellsUrlsArray[indexPath.row]
    }
    
    func removeVideo(url: URL) -> Error? {
        do {
            if let locationPath = UserDefaultsManager.getVideoLocationPath(url: url) {
                let baseURL = URL(fileURLWithPath: NSHomeDirectory())
                let assetURL = baseURL.appendingPathComponent(locationPath)
                
                try FileManager.default.removeItem(at: assetURL)
            }
        } catch {
            if let i = cellsUrlsArray.firstIndex(of: url) {
                cellsUrlsArray.remove(at: i)
            }
            
            UserDefaultsManager.removeVideo(url: url)
            
            print(error)
            return error
        }
        
        if let i = cellsUrlsArray.firstIndex(of: url) {
            cellsUrlsArray.remove(at: i)
        }
        
        UserDefaultsManager.removeVideo(url: url)
        return nil
    }
}

