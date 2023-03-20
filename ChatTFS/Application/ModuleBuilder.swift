import Foundation

protocol ModuleBuilderProtocol: AnyObject {
    func buildConvList(router: RouterProtocol) -> ConvListViewController
    func buildProfile(router: RouterProtocol, profile: ProfileModel) -> ProfileViewController
    func buildConversation(router: RouterProtocol, conversation: ConversationListModel) -> ConversationViewController
    func buildThemePicker() -> ThemesViewController
}

class ModuleBuilder: ModuleBuilderProtocol {
    
    //MARK: - Private
    private lazy var themeService = ThemeService()
    
    //MARK: - Methods
    func buildConvList(router: RouterProtocol) -> ConvListViewController {
        let interactor = ConvListInteractor()
        let presenter = ConvListPresenter(router: router, interactor: interactor)
        let view = ConvListViewController(themeService: themeService)
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        return view
    }

    func buildProfile(router: RouterProtocol, profile: ProfileModel) -> ProfileViewController {
        let interactor = ProfileInteractor()
        let view = ProfileViewController(themeService: themeService)
        let presenter = ProfilePresenter(router: router, interactor: interactor, profile: profile)
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
