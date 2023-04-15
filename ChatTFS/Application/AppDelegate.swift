//
//  AppDelegate.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Public properties
    
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    // MARK: - Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let moduleBuilder = ModuleBuilder()
        let tabBarController = moduleBuilder.buildTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        return true
    }
}
