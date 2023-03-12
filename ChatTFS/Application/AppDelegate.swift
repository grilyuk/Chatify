//
//  AppDelegate.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //MARK: Properties
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    //MARK: Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let moduleBuilder = ModuleBuilder()
        let navigationController = UINavigationController()
        let router = Router(navigationController: navigationController, moduleBuilder: moduleBuilder)
        router.initialViewController()
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}
