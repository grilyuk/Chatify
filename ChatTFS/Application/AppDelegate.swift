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
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
        return true
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let firstVC = FirstViewController()
        window?.rootViewController = firstVC
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        actualState = getState(state: application.applicationState)
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let secVC = SecondViewController()
        window?.rootViewController = secVC
//метод уменуется как WILL resign active, метода didResignActive не предусмотренно, но по документации, здесь мы преходим в state Inactive, поэтому задал actualState вручную
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
        let firstVC = FirstViewController()
        window?.rootViewController = firstVC
//по аналогии с willResignActive, при вызове этого метода приложение только БУДЕТ переведено в Inactive
        actualState = "Inactive"
        print("Application moved from \(previousState) to \(actualState): \(#function)")
        previousState = actualState
    }

    func applicationWillTerminate(_ application: UIApplication) {
        actualState = "Not Running"
        print("Application moved from \(previousState) to \(actualState): \(#function)")
    }

//могу предположить, что стейт Suspended в AppDelegate отловить невозможно, так как система не вызывает какой либо метод в AppDelegate, а таковой метод и не предусмотрен. Причина по которой его не предусмотрели, наверняка в том, что когда приложение переходит в Suspended, оно вообще не выполняет какого либо кода, а остается в памяти. Даже если представить что у нас есть условный didBecomeSuspended(), код в этом методе не будет выполняться, потому что приложение перешло в Suspended и никакого кода выполнять не может,  поэтому и в действительности подобного метода нет, он будет бессмысленным. *надеюсь это предположение похоже на правду*
}

//Метод ниже реализует отключение логирования, необходимо в Edit scheme переключить Build Configuration на Release. 
public func print(_ object: Any) {
#if DEBUG
    Swift.print(object)
#endif
}
