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
    private lazy var logoEmitterAnimation = EmitterAnimation()

    // MARK: - Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let moduleBuilder = ModuleAssembly(serviceAssembly: serviceAssembly)
        let tabBarController = moduleBuilder.buildTabBarController()
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanTouch(sender: )))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapTouch(sender: )))
        tapGesture.cancelsTouchesInView = false
        panGesture.cancelsTouchesInView = false
        window?.addGestureRecognizer(panGesture)
        window?.addGestureRecognizer(tapGesture)
        switch serviceAssembly.themeService.currentTheme {
        case .light:
            application.windows[0].overrideUserInterfaceStyle = .light
        case .dark:
            application.windows[0].overrideUserInterfaceStyle = .dark
        }
        return true
    }
    
    @objc
    private func handlePanTouch(sender: UIGestureRecognizer) {
        logoEmitterAnimation.birthRate = 50
        logoEmitterAnimation.setupLogoLayer(layer: logoEmitterAnimation)
        let location = sender.location(in: window)
        logoEmitterAnimation.emitterPosition = location
        window?.layer.addSublayer(logoEmitterAnimation)
        if sender.state == .ended {
            logoEmitterAnimation.birthRate = 0
        }
    }
    
    @objc func handleTapTouch(sender: UIGestureRecognizer) {
        logoEmitterAnimation.birthRate = 10
        logoEmitterAnimation.setupLogoLayer(layer: logoEmitterAnimation)
        let location = sender.location(in: window?.inputView)
        logoEmitterAnimation.emitterPosition = location
        window?.layer.addSublayer(logoEmitterAnimation)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.logoEmitterAnimation.birthRate = 0
        }
    }
}
