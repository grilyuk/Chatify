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

    var actualState = ""
    var previousState = ""

    //MARK: Method for displaying the application state as string
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
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        actualState = getState(state: application.applicationState)
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
    }

    func applicationWillResignActive(_ application: UIApplication) {
//метод уменуется как WILL resign active, метода didResignActive не предусмотренно, но по документации, здесь мы преходим в state Inactive, поэтому задал nowState вручную
        actualState = "Inactive"
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        actualState = getState(state: application.applicationState)
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
//по аналогии с willResignActive
        actualState = "Inactive"
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
    }

    func applicationWillTerminate(_ application: UIApplication) {
        actualState = "Not Running"
        print("Application moved from \(previousState) to \(actualState): \(#function)")
    }
//можно отметить, что state Suspended в AppDelegate отловить невозможно, так как в этот state приложение переводит сама система, AppDelegate о нем не знает
}
