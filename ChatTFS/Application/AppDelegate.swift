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
    var window: UIWindow?

    let log = Logger(shouldLog: false)
    var actualState = ""
    var previousState = ""

    //MARK: Method for show the application state as string
    func getState(state: UIApplication.State) -> String {
        switch state {
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .background:
            return "Background"
        default:
            return "Some error"
        }
    }

    //MARK: App Lifecycle methods
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        previousState = "Not running"
        actualState = getState(state: application.applicationState)
        log.handleLog(actualState: actualState, previousState: previousState)
        previousState = actualState
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainVC = MainViewController()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        actualState = getState(state: application.applicationState)
        log.handleLog(actualState: actualState, previousState: previousState)
        previousState = actualState
    }

    func applicationWillResignActive(_ application: UIApplication) {
        actualState = "Inactive"
        log.handleLog(actualState: actualState, previousState: previousState)
        previousState = actualState
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        actualState = getState(state: application.applicationState)
        log.handleLog(actualState: actualState, previousState: previousState)
        previousState = actualState
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        let firstVC = MainViewController()
        window?.rootViewController = firstVC
        actualState = "Inactive"
        log.handleLog(actualState: actualState, previousState: previousState)
        previousState = actualState
    }

    func applicationWillTerminate(_ application: UIApplication) {
        actualState = "Not Running"
        log.handleLog(actualState: actualState, previousState: previousState)
    }
}
