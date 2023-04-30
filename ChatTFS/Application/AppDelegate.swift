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
    
    // MARK: - Private properties
    
    private lazy var coreAssembly = CoreAssembly()
    private lazy var serviceAssembly = ServiceAssembly(coreAssembly: coreAssembly)

    // MARK: - Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let moduleBuilder = ModuleAssembly(serviceAssembly: serviceAssembly)
        let tabBarController = moduleBuilder.buildTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        switch serviceAssembly.themeService.currentTheme {
        case .light:
            application.windows[0].overrideUserInterfaceStyle = .light
        case .dark:
            application.windows[0].overrideUserInterfaceStyle = .dark
        }
        return true
    }
    
//    @objc func handleTapTouch(sender: UIGestureRecognizer) {
//        let location = sender.location(in: window)
//        let newSnowLayer = CAEmitterLayer()
//        setupSnowLayer(layer: newSnowLayer)
//        newSnowLayer.emitterPosition = location
//        newSnowLayer.lifetime = 5
//        window?.layer.addSublayer(newSnowLayer)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            newSnowLayer.birthRate = 0
//        }
//    }
}
