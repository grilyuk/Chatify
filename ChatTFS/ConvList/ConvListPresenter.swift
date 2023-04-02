import UIKit

protocol ConvListPresenterProtocol: AnyObject {
    var router: RouterProtocol? {get set}
    var profile: ProfileModel? { get set }
    var users: [ConversationListModel]? { get set }
    func viewReady()
    func dataUploaded()
    func didTappedConversation(for conversation: ConversationListModel, navigationController: UINavigationController)
    var handler: (([ConversationListModel]) -> Void)? { get set }
}

class ConvListPresenter {
    
    // MARK: - Public
    
    weak var view: ConvListViewProtocol?
    var router: RouterProtocol?
    let interactor: ConvListInteractorProtocol
    var profile: ProfileModel?
    var users: [ConversationListModel]?
    var handler: (([ConversationListModel]) -> Void)?
    
    // MARK: - Initialization
    
    init(interactor: ConvListInteractorProtocol) {
        self.interactor = interactor
    }
}

// MARK: - ConvListPresenter + ConvListPresenterProtocol

extension ConvListPresenter: ConvListPresenterProtocol {
    
    // MARK: - Methods
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
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
        
        handler = { [weak self] sortedUsers in
            self?.view?.users = sortedUsers
            self?.view?.showMain()
        }
        
        handler?(sortedUsers)
    }
    
    func didTappedConversation(for conversation: ConversationListModel, navigationController: UINavigationController) {
        router?.showConversation(conversation: conversation, navigationController: navigationController)
    }
    
    func createChannel(name: String) {
//        interactor.
    }
}
