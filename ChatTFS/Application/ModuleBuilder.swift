import Foundation
import UIKit
import TFSChatTransport

protocol ModuleBuilderProtocol: AnyObject {
    func buildConvList() -> UINavigationController
    func buildProfile() -> UINavigationController
    func buildConversation(router: RouterProtocol, conversation: String) -> ConversationViewController
    func buildThemePicker() -> UINavigationController
    func buildTabBarController() -> UITabBarController
}

class ModuleBuilder: ModuleBuilderProtocol {
    
    // MARK: - Private
    
    private lazy var themeService = ThemeService()
    private lazy var dataManager = DataManager()
    private lazy var profilePublisher = dataManager.currentProfile
    private lazy var chatService = ChatService(host: "167.235.86.234", port: 8080)
    
    // MARK: - Methods
    
    func buildConvList() -> UINavigationController {
        let interactor = ConvListInteractor(dataManager: dataManager, chatService: chatService)
        let presenter = ConvListPresenter(interactor: interactor)
        let view = ConvListViewController(themeService: themeService)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        let navigationController = UINavigationController(rootViewController: view)
        presenter.router = Router(navigationController: navigationController, moduleBuilder: self)
        return navigationController
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
    
    func buildConversation(router: RouterProtocol, conversation: String) -> ConversationViewController {
        let interactor = ConversationInteractor(chatService: chatService, channelID: conversation)
        let presenter = ConversationPresenter(router: router, interactor: interactor)
        let view = ConversationViewController(themeService: themeService)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
    
    func buildThemePicker() -> UINavigationController {
        let view = ThemesViewController(themeService: themeService)
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func buildTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        let views = [buildConvList(), buildThemePicker(), buildProfile()]
        tabBarController.tabBar.barTintColor = themeService.currentTheme.backgroundColor
        tabBarController.viewControllers = views
        tabBarController.tabBar.items?[0].image = UIImage(systemName: "bubble.left.and.bubble.right")
        tabBarController.tabBar.items?[0].title = "Conversation"
        tabBarController.tabBar.items?[1].image = UIImage(systemName: "gear")
        tabBarController.tabBar.items?[1].title = "Settings"
        tabBarController.tabBar.items?[2].image = UIImage(systemName: "person.crop.circle")
        tabBarController.tabBar.items?[2].title = "Profile"
        return tabBarController
    }
}
