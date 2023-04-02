import UIKit

protocol ConversationPresenterProtocol: AnyObject {
    var historyChat: [MessageCellModel]? { get set }
    var handler: (([MessageCellModel], String) -> Void)? { get set }
    func viewReady()
    func dataUploaded()
}

class ConversationPresenter {
    
    // MARK: - Public
    
    weak var view: ConversationViewProtocol?
    let router: RouterProtocol?
    let interactor: ConversationInteractorProtocol
    let conversation: ConversationListModel?
    var historyChat: [MessageCellModel]?
    var handler: (([MessageCellModel], String) -> Void)?
    
    // MARK: - Initialization
    
    init(router: RouterProtocol, interactor: ConversationInteractorProtocol, conversation: ConversationListModel) {
        self.router = router
        self.interactor = interactor
        self.conversation = conversation
    }
}

// MARK: - ConversationPresenter + ConversationPresenterProtocol

extension ConversationPresenter: ConversationPresenterProtocol {
    
    // MARK: - Methods
    
    func viewReady() {
        interactor.loadData()
        let userName = conversation?.name ?? ""
        guard let historyChat = historyChat else {return}
        handler = { [weak self] history, userName in
            self?.view?.historyChat = history
            self?.view?.userName = userName
            
        }
        handler?(historyChat, userName)
    }
    
    func dataUploaded() {
        view?.showConversation()
    }
}
