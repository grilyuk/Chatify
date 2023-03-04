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
    let log = Logger(shouldLog: false, logType: .app)
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

    //MARK: Lifecycle
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        previousState = "Not running"
        actualState = getState(state: application.applicationState)
        log.handleLog(actualState: actualState, previousState: previousState)
        previousState = actualState
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.overrideUserInterfaceStyle = .light
        let mainVC = MainModuleBuilder().mainBuild()
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
        actualState = "Inactive"
        log.handleLog(actualState: actualState, previousState: previousState)
        previousState = actualState
    }

    func applicationWillTerminate(_ application: UIApplication) {
        actualState = "Not Running"
        log.handleLog(actualState: actualState, previousState: previousState)
    }
}
