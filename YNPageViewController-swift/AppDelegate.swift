//
//  AppDelegate.swift
//  YNPageViewController-swift
//
//  Created by Yun Wang 王云 on 2022/3/1.
//

import UIKit
@_exported import SnapKit
@_exported import MJRefresh

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        
        self.window?.rootViewController = YNNavigationController(rootViewController: DemosListVC())
        self.window?.makeKeyAndVisible()
        
        return true
    }


}

