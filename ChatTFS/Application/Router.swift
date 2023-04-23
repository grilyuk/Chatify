import UIKit
import TFSChatTransport

protocol RouterMain: AnyObject {
    var moduleBuilder: ModuleAssemblyProtocol? {get set}
}

protocol RouterProtocol: RouterMain {
    func showChannel(channel: String, navigationController: UINavigationController)
    func showNetworkImages(navigationController: UINavigationController, profileVC: ProfileViewProtocol)
}

class Router: RouterProtocol {
    
    // MARK: - Initialization
    
    init(moduleBuilder: ModuleAssemblyProtocol) {
        self.moduleBuilder = moduleBuilder
    }
    
    // MARK: - Public properties
    
    var moduleBuilder: ModuleAssemblyProtocol?
    
    // MARK: - Public methods
    
    func showChannel(channel: String, navigationController: UINavigationController) {
        guard let channelViewController = moduleBuilder?.buildChannel(router: self, channel: channel) else { return }
        navigationController.pushViewController(channelViewController, animated: true)
    }
    
    func showNetworkImages(navigationController: UINavigationController, profileVC: ProfileViewProtocol) {
        guard let networkImages = moduleBuilder?.buildNetworkImages(router: self, profileVC: profileVC) else { return }
        navigationController.present(networkImages, animated: true)
    }
}
