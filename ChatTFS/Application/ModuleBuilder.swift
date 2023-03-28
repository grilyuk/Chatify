import Foundation
//import Combine

protocol ModuleBuilderProtocol: AnyObject {
    func buildConvList(router: RouterProtocol) -> ConvListViewController
    func buildProfile(router: RouterProtocol) -> ProfileViewController
    func buildConversation(router: RouterProtocol, conversation: ConversationListModel) -> ConversationViewController
    func buildThemePicker() -> ThemesViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    
    //MARK: - Private
    private lazy var themeService = ThemeService()
    private lazy var dataManager = DataManager()
    private lazy var readProfilePublisher = dataManager.readProfilePublisher()
    
    //MARK: - Methods
    func buildConvList(router: RouterProtocol) -> ConvListViewController {
        let interactor = ConvListInteractor(profilePublisher: readProfilePublisher)
        let presenter = ConvListPresenter(router: router, interactor: interactor)
        let view = ConvListViewController(themeService: themeService, dataManager: dataManager)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }

    func buildProfile(router: RouterProtocol) -> ProfileViewController {
        let interactor = ProfileInteractor(profilePublisher: readProfilePublisher, dataManager: dataManager)
        let presenter = ProfilePresenter(router: router, interactor: interactor)
        let view = ProfileViewController(themeService: themeService, profilePublisher: readProfilePublisher)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
    
    func buildConversation(router: RouterProtocol, conversation: ConversationListModel) -> ConversationViewController {
        let interactor = ConversationInteractor()
        let presenter = ConversationPresenter(router: router, interactor: interactor, conversation: conversation)
        let view = ConversationViewController(themeService: themeService)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
    
    func buildThemePicker() -> ThemesViewController {
        let view = ThemesViewController(themeService: themeService)
        return view
    }
}
