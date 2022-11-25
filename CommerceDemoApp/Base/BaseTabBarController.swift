//
//  BaseTabBarController.swift
//  CommerceDemoApp
//
//  Created by 이아연 on 2022/11/25.
//

import UIKit

class BaseTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setupTabBar()
    }
    
    func setupTabBar() {
        let homeIcon = UITabBarItem(title: "홈",
                                    image: UIImage(systemName: "house"),
                                    selectedImage: UIImage(systemName: "house.fill")!)
        let likeIcon = UITabBarItem(title: "좋아요",
                                    image: UIImage(systemName: "heart"),
                                    selectedImage: UIImage(systemName: "heart.fill")!)
        
        tabBar.tintColor = .appColor(.deepRosePink)
        
        let homeVC = HomeViewController()
        homeVC.hidesBottomBarWhenPushed = false
        let homeNavigation = UINavigationController(rootViewController: homeVC)
        homeNavigation.tabBarItem = homeIcon
        
        let likeVC = LikeViewController()
        likeVC.hidesBottomBarWhenPushed = false
        let likeNavigation = UINavigationController(rootViewController: likeVC)
        likeNavigation.tabBarItem = likeIcon
        
        self.viewControllers = [homeNavigation, likeNavigation]
    }
}
