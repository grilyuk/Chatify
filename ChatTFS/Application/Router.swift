import UIKit

protocol RouterMain: AnyObject {
    var navigationController: UINavigationController? {get set}
    var moduleBuilder: ModuleBuilderProtocol? {get set}
}

protocol RouterProtocol: RouterMain {
    func initialViewController()
    func showProfile()
    func showConversation(conversation: ConversationListModel)
    func showThemePicker()
}

class Router: RouterProtocol {
    
    //MARK: - Public
    weak var navigationController: UINavigationController?
    var moduleBuilder: ModuleBuilderProtocol?
    
    //MARK: - Init
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    
    //MARK: - Methods
    func initialViewController() {
        if let navigationController = navigationController {
            guard let mainViewController = moduleBuilder?.buildConvList(router: self) else { return }
            navigationController.viewControllers = [mainViewController]
        }
    }
    
    func showProfile() {
        if let navigationController = navigationController {
            guard let profileViewController = moduleBuilder?.buildProfile(router: self) else { return }
            navigationController.present(profileViewController, animated: true)
        }
    }
    
    func showConversation(conversation: ConversationListModel) {
        if let navigationController = navigationController {
            guard let conversationViewController = moduleBuilder?.buildConversation(router: self, conversation: conversation) else { return }
            navigationController.pushViewController(conversationViewController, animated: true)
        }
    }
    
    func showThemePicker() {
        if let navigationController = navigationController {
            guard let themeViewController = moduleBuilder?.buildThemePicker() else { return }
            navigationController.pushViewController(themeViewController, animated: true)
        }
    }
}
