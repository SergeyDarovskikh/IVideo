//
//  TabBarController.swift
//  IVideo
//
//  Created by Сергей Даровских on 18.02.2022.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let searchVideoViewController = SearchVideoViewController()

        let searchVideoTabBarItem = UITabBarItem(title: "Search",
                                                 image: UIImage(systemName: "magnifyingglass"),
                                                 selectedImage: UIImage(named: "magnifyingglass"))

        searchVideoViewController.tabBarItem = searchVideoTabBarItem
        searchVideoViewController.tabBarItem.tag = 0

        let libraryVideosViewController = LibraryVideosViewController()
        
        let libraryVideosTabBarItem = UITabBarItem(title: "Labrary",
                                                   image: UIImage(systemName: "rectangle.stack.fill"),
                                                   selectedImage: UIImage(named: "rectangle.stack.fill"))

        libraryVideosViewController.tabBarItem = libraryVideosTabBarItem
        libraryVideosViewController.tabBarItem.tag = 1

        let tabBarList = [searchVideoViewController, libraryVideosViewController]

        viewControllers = tabBarList.map{UINavigationController(rootViewController: $0)}

    }
}
