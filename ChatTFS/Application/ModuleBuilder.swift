import Foundation

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
    
    //MARK: - Methods
    func buildConvList(router: RouterProtocol) -> ConvListViewController {
        let interactor = ConvListInteractor(dataManager: dataManager)
        let presenter = ConvListPresenter(router: router, interactor: interactor)
        let view = ConvListViewController(themeService: themeService, dataManager: dataManager)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }

    func buildProfile(router: RouterProtocol) -> ProfileViewController {
        let interactor = ProfileInteractor(dataManager: dataManager)
        let view = ProfileViewController(themeService: themeService, dataManager: dataManager)
        let presenter = ProfilePresenter(router: router, interactor: interactor)
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
