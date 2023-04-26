import Foundation
import UIKit
import TFSChatTransport

protocol ModuleAssemblyProtocol: AnyObject {
    func buildChannelsList() -> UINavigationController
    func buildProfile() -> UINavigationController
    func buildChannel(router: RouterProtocol, channel: String) -> ChannelViewController
    func buildThemePicker() -> UINavigationController
    func buildTabBarController() -> UITabBarController
    func buildNetworkImages(router: RouterProtocol, profileVC: ProfileViewProtocol) -> UINavigationController
}

class ModuleAssembly: ModuleAssemblyProtocol {
    
    // MARK: - Initialization
    
    init(serviceAssembly: ServiceAssemblyProtocol) {
        self.serviceAssembly = serviceAssembly
    }
    
    // MARK: - Private properties
    
    private var serviceAssembly: ServiceAssemblyProtocol
    
    private lazy var router = Router(moduleBuilder: self)
    private lazy var themeService = serviceAssembly.themeService
    private lazy var dataManager = serviceAssembly.fileManagerService
    private lazy var coreDataService = serviceAssembly.coreDataService
    private lazy var profilePublisher = dataManager.currentProfile
    private lazy var chatService = serviceAssembly.chatService
    private lazy var imageLoaderService = serviceAssembly.imageLoaderService
    
    // MARK: - Public Methods
    
    func buildChannelsList() -> UINavigationController {
        let interactor = ChannelsListInteractor(chatService: chatService,
                                                coreDataService: coreDataService,
                                                dataManager: dataManager)
        let presenter = ChannelsListPresenter(interactor: interactor)
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
                                           coreDataService: coreDataService,
                                           dataManager: dataManager)
        let presenter = ChannelPresenter(router: router, interactor: interactor)
        let view = ChannelViewController(themeService: themeService)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
    
    func buildProfile() -> UINavigationController {
        let interactor = ProfileInteractor(dataManager: dataManager)
        let presenter = ProfilePresenter(interactor: interactor, router: router)
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
        tabBarController.tabBar.items?[0].title = "Channels"
        tabBarController.tabBar.items?[1].image = UIImage(systemName: "gear")
        tabBarController.tabBar.items?[1].title = "Settings"
        tabBarController.tabBar.items?[2].image = UIImage(systemName: "person.crop.circle")
        tabBarController.tabBar.items?[2].title = "Profile"
        return tabBarController
    }
    
    func buildNetworkImages(router: RouterProtocol, profileVC: ProfileViewProtocol) -> UINavigationController {
        let interactor = NetworkImagesInteractor(imageLoader: imageLoaderService)
        let presenter = NetworkImagesPresenter(interactor: interactor)
        let view = NetworkImagesViewController(themeService: themeService)
        view.presenter = presenter
        view.profileVC = profileVC
        interactor.presenter = presenter
        presenter.view = view
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
}
