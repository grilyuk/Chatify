import UIKit

protocol RouterMain: AnyObject {
    var navigationController: UINavigationController? {get set}
    var moduleBuilder: ModuleBuilderProtocol? {get set}
}

protocol RouterProtocol: RouterMain {
    func showConversation(conversation: ConversationListModel, navigationController: UINavigationController)
}

class Router: RouterProtocol {
    
    // MARK: - Public
    
    weak var navigationController: UINavigationController?
    var moduleBuilder: ModuleBuilderProtocol?
    
    // MARK: - Init
    
    init(navigationController: UINavigationController, moduleBuilder: ModuleBuilderProtocol) {
        self.navigationController = navigationController
        self.moduleBuilder = moduleBuilder
    }
    
    // MARK: - Methods
    
    func showConversation(conversation: ConversationListModel, navigationController: UINavigationController) {
        guard let conversationViewController = moduleBuilder?.buildConversation(router: self, conversation: conversation) else { return }
        navigationController.pushViewController(conversationViewController, animated: true)
        
    }
}
