//
//  AppDelegate.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 16.02.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Application moved from \"Not Running\" to \"Inactive\": \(#function)")
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("Application moved from \"Inactive\" to \"Active\" \(#function)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("Application moved from \"Active\" to \"Inactive\" \(#function)")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Application moved from \"Inactive\" to \"Background\" \(#function)")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Application moved from \"Background\" to \"Inactive\" \(#function)")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("Application moved from \"Background\" to \"Not Running\" \(#function)")
    }
}
