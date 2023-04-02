import Foundation

protocol ConversationInteractorProtocol: AnyObject {
    func loadData()
    var handler: (([MessageCellModel]) -> Void)? { get set }
}

class ConversationInteractor: ConversationInteractorProtocol {
    
    // MARK: - Public
    
    weak var presenter: ConversationPresenterProtocol?
    var handler: (([MessageCellModel]) -> Void)?
    
    // MARK: - Methods
    
    func loadData() {
        let historyChat = [
            MessageCellModel(text: "Тестим тестим тестим \nТестим ттим тестим тестим", date: Date(timeIntervalSinceNow: 215125), myMessage: false)
        ]
        handler = { [weak self] history in
            self?.presenter?.historyChat = history
            self?.presenter?.dataUploaded()
        }
        handler?(historyChat)
    }
}
