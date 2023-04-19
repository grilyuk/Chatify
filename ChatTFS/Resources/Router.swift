import UIKit
import TFSChatTransport

protocol RouterMain: AnyObject {
    var moduleBuilder: ModuleBuilderProtocol? {get set}
}

protocol RouterProtocol: RouterMain {
    func showChannel(channel: String, navigationController: UINavigationController)
}

class Router: RouterProtocol {
    
    // MARK: - Initialization
    
    init(moduleBuilder: ModuleBuilderProtocol) {
        self.moduleBuilder = moduleBuilder
    }
    
    // MARK: - Public properties
    
    var moduleBuilder: ModuleBuilderProtocol?
    
    // MARK: - Public methods
    
    func showChannel(channel: String, navigationController: UINavigationController) {
        guard let channelViewController = moduleBuilder?.buildChannel(router: self, channel: channel) else { return }
        navigationController.pushViewController(channelViewController, animated: true)
    }
}
