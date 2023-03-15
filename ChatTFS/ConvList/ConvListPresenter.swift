import UIKit

protocol ConvListPresenterProtocol: AnyObject {
    var profile: ProfileModel? { get set }
    var users: [ConversationListModel]? { get set }
    var handler: ((ProfileModel, [ConversationListModel]) -> Void)? { get set }
    func viewReady()
    func dataUploaded()
    func didTappedProfile()
    func didTappedThemesPicker()
    func didTappedConversation(for conversation: ConversationListModel)
}

class ConvListPresenter {
    
    //MARK: - Public
    weak var view: ConvListViewProtocol?
    var router: RouterProtocol?
    let interactor: ConvListInteractorProtocol
    var profile: ProfileModel?
    var users: [ConversationListModel]?
    var handler: ((ProfileModel, [ConversationListModel]) -> Void)?
    
    //MARK: - Initializer
    init(router: RouterProtocol, interactor: ConvListInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

//MARK: - ConvListPresenter + ConvListPresenterProtocol
extension ConvListPresenter: ConvListPresenterProtocol {
    
    //MARK: - Methods
    func viewReady() {
        handler = { [weak self] meProfile, unsortUsers in
            self?.profile = meProfile
            self?.users = unsortUsers
        }
        
        interactor.loadData()

        var usersWithMessages: [ConversationListModel] = []
        var usersWithoutMessages: [ConversationListModel] = []
        guard let users = users else { return }
        for user in users {
            switch user.date != nil {
            case true: usersWithMessages.append(user)
            case false: usersWithoutMessages.append(user)
            }
        }
        
        var sortedUsers = usersWithMessages.sorted { $0.date ?? Date() > $1.date ?? Date() }
        sortedUsers.append(contentsOf: usersWithoutMessages)

        view?.handler?(sortedUsers)
    }
    
    func dataUploaded() {
        view?.showMain()
    }
    
    func didTappedProfile() {
        guard let profile = profile else { return }
        router?.showProfile(profile: profile)
    }
    
    func didTappedConversation(for conversation: ConversationListModel) {
        router?.showConversation(conversation: conversation)
    }
    
    func didTappedThemesPicker() {
        router?.showThemePicker()
    }
}
