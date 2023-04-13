import UIKit
import TFSChatTransport

protocol ConversationPresenterProtocol: AnyObject {
    var handler: ((ChannelModel, [MessageCellModel]) -> Void)? { get set }
    var messagesData: [Message]? { get set }
    var channelData: Channel? { get set }
    func viewReady()
    func dataUploaded(userID: String)
    func uploadMessage(messageModel: Message)
    func createMessage(messageText: String?)
}

class ConversationPresenter {
    
    // MARK: - Public
    
    weak var view: ConversationViewProtocol?
    let router: RouterProtocol?
    let interactor: ConversationInteractorProtocol
    var messagesData: [Message]?
    var channelData: Channel?
    var handler: ((ChannelModel, [MessageCellModel]) -> Void)?
    
    // MARK: - Initialization
    
    init(router: RouterProtocol, interactor: ConversationInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

// MARK: - ConversationPresenter + ConversationPresenterProtocol

extension ConversationPresenter: ConversationPresenterProtocol {
    
    // MARK: - Methods
    
    func createMessage(messageText: String?) {
        if messageText == nil && messageText == "" {
        } else {
            interactor.createMessageData(messageText: messageText ?? "")
        }
    }
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded(userID: String) {
        
        handler = { [weak self] channel, messages in
            self?.view?.messages = messages
            self?.view?.showConversation(channel: channel)
        }
        
        var currentUserID = ""
        var messages: [MessageCellModel] = []
        messagesData?.forEach({ message in
            if message.userID == userID && message.text != "" {
                messages.append(MessageCellModel(text: message.text,
                                                 date: message.date,
                                                 myMessage: true,
                                                 userName: message.userName,
                                                 isSameUser: true))
            } else if message.text != "" {
                let isSameUser = {
                    if currentUserID == message.userID {
                        return true
                    } else {
                        currentUserID = message.userID
                        return false
                    }
                }()
                messages.append(MessageCellModel(text: message.text,
                                                 date: message.date,
                                                 myMessage: false,
                                                 userName: message.userName,
                                                 isSameUser: isSameUser))
            }
        })
        
        DispatchQueue.global().async { [weak self] in
            guard let channelName = self?.channelData?.name else { return }
            let channelImage: UIImage = {
                var image = UIImage(systemName: "circle.slash") ?? UIImage()
                do {
                    guard let imageURLString = self?.channelData?.logoURL,
                          let imageURL = URL(string: imageURLString)
                    else { return image }
                    let imageData = try Data(contentsOf: imageURL)
                    image = UIImage(data: imageData) ?? UIImage()
                } catch {
                    print(CustomError(description: "Error convert conversation image"))
                }
                return image
            }()
            
            let channel = ChannelModel(channelName: channelName, channelImage: channelImage)
            
            DispatchQueue.main.async { [weak self] in
                self?.handler?(channel, messages)
            }
        }
    }
    
    func uploadMessage(messageModel: Message) {
        view?.addMessage(message: MessageCellModel(text: messageModel.text,
                                                   date: messageModel.date,
                                                   myMessage: true,
                                                   userName: "",
                                                   isSameUser: true))
    }
}
