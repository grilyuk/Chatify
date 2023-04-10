import Foundation
import UIKit
import TFSChatTransport

protocol ModuleBuilderProtocol: AnyObject {
    func buildChannelsList() -> UINavigationController
    func buildProfile() -> UINavigationController
    func buildChannel(router: RouterProtocol, channel: String) -> ChannelViewController
    func buildThemePicker() -> UINavigationController
    func buildTabBarController() -> UITabBarController
}

class ModuleBuilder: ModuleBuilderProtocol {
    
    // MARK: - Private
    
    private lazy var router = Router(moduleBuilder: self)
    private lazy var themeService = ThemeService()
    private lazy var dataManager = DataManager()
    private lazy var coreDataService = CoreDataService()
    private lazy var profilePublisher = dataManager.currentProfile
    private lazy var chatService = ChatService(host: "167.235.86.234", port: 8080)
    
    // MARK: - Methods
    
    func buildChannelsList() -> UINavigationController {
        let interactor = ChannelsListInteractor(chatService: chatService, coreDataService: coreDataService)
        let presenter = ChannelsListPresenter(interactor: interactor, dataManager: dataManager)
        let view = ChannelsListViewController(themeService: themeService)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        let navigationController = UINavigationController(rootViewController: view)
        presenter.router = router
        return navigationController
    }

    func buildChannel(router: RouterProtocol, channel: String) -> ChannelViewController {
        let interactor = ChannelInteractor(chatService: chatService,
                                           channelID: channel,
                                           dataManager: dataManager,
                                           coreDataService: coreDataService)
        let presenter = ChannelPresenter(router: router, interactor: interactor)
        let view = ChannelViewController(themeService: themeService)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
    
    func buildProfile() -> UINavigationController {
        let interactor = ProfileInteractor(dataManager: dataManager)
        let presenter = ProfilePresenter(interactor: interactor)
        let view = ProfileViewController(themeService: themeService, profilePublisher: profilePublisher)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func buildThemePicker() -> UINavigationController {
        let view = ThemesViewController(themeService: themeService)
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func buildTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        let views = [buildChannelsList(), buildThemePicker(), buildProfile()]
        tabBarController.tabBar.barTintColor = themeService.currentTheme.backgroundColor
        tabBarController.viewControllers = views
        tabBarController.tabBar.items?[0].image = UIImage(systemName: "bubble.left.and.bubble.right")
        tabBarController.tabBar.items?[0].title = "Channel"
        tabBarController.tabBar.items?[1].image = UIImage(systemName: "gear")
        tabBarController.tabBar.items?[1].title = "Settings"
        tabBarController.tabBar.items?[2].image = UIImage(systemName: "person.crop.circle")
        tabBarController.tabBar.items?[2].title = "Profile"
        return tabBarController
    }
}
