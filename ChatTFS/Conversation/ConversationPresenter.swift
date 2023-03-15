import UIKit

protocol ConversationPresenterProtocol: AnyObject {
    var handler: (([MessageCellModel]) -> Void)? { get set }
    func viewReady()
    func dataUploaded()
}

class ConversationPresenter {
    
    //MARK: - Public
    weak var view: ConversationViewProtocol?
    let router: RouterProtocol?
    let interactor: ConversationInteractorProtocol
    let conversation: ConversationListModel?
    var historyChat: [MessageCellModel]?
    var handler: (([MessageCellModel]) -> Void)?
    
    //MARK: - Initializer
    init(router: RouterProtocol, interactor: ConversationInteractorProtocol, conversation: ConversationListModel) {
        self.router = router
        self.interactor = interactor
        self.conversation = conversation
    }
}

//MARK: - ConversationPresenter + ConversationPresenterProtocol
extension ConversationPresenter: ConversationPresenterProtocol {
    
    //MARK: - Methods
    func viewReady() {
        handler = { [weak self] history in
            self?.historyChat = history
        }
        interactor.loadData()
        let userName = conversation?.name ?? ""
        guard let historyChat = historyChat else {return}
        view?.handler?(historyChat, userName)
    }
    
    func dataUploaded() {
        view?.showConversation()
    }
}
