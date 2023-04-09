import UIKit
import TFSChatTransport

protocol RouterMain: AnyObject {
    var navigationController: UINavigationController? {get set}
    var moduleBuilder: ModuleBuilderProtocol? {get set}
}

protocol RouterProtocol: RouterMain {
    func showChannel(channel: String, navigationController: UINavigationController)
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
    
    func showChannel(channel: String, navigationController: UINavigationController) {
        guard let channelViewController = moduleBuilder?.buildChannel(router: self, channel: channel) else { return }
        navigationController.pushViewController(channelViewController, animated: true)
    }
}
