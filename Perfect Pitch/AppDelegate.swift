//
//  AppDelegate.swift
//  Perfect Pitch
//
//  Created by Jia Rui Shan on 2023/2/13.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = HomeNavigationController(rootViewController: HomeViewController())
        window?.makeKeyAndVisible()
        
        return true
    }


}

