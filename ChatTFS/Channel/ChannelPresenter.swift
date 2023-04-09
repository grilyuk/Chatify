import UIKit
import TFSChatTransport

protocol ChannelPresenterProtocol: AnyObject {
    var handler: ((ChannelModel, [MessageModel]) -> Void)? { get set }
    var messagesData: [Message]? { get set }
    var channelData: Channel? { get set }
    func viewReady()
    func dataUploaded(userID: String)
    func uploadMessage(messageModel: Message)
    func createMessage(messageText: String?)
}

class ChannelPresenter {
    
    // MARK: - Public
    
    weak var view: ChannelViewProtocol?
    let router: RouterProtocol?
    let interactor: ChannelInteractorProtocol
    var messagesData: [Message]?
    var channelData: Channel?
    var handler: ((ChannelModel, [MessageModel]) -> Void)?
    
    // MARK: - Initialization
    
    init(router: RouterProtocol, interactor: ChannelInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

// MARK: - ChannelPresenter + ChannelPresenterProtocol

extension ChannelPresenter: ChannelPresenterProtocol {
    
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
            self?.view?.showChannel(channel: channel)
        }
        
        var currentUserID = ""
        var messages: [MessageModel] = []
        messagesData?.forEach({ message in
            if message.userID == userID && message.text != "" {
                messages.append(MessageModel(text: message.text,
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
                messages.append(MessageModel(text: message.text,
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
                    print(CustomError(description: "Error convert channel image"))
                }
                return image
            }()
            
            let channel = ChannelModel(channelImage: channelImage,
                                       name: channelName,
                                       message: nil,
                                       date: nil,
                                       isOnline: false,
                                       hasUnreadMessages: nil,
                                       channelID: nil)
            
            DispatchQueue.main.async { [weak self] in
                self?.handler?(channel, messages)
            }
        }
    }
    
    func uploadMessage(messageModel: Message) {
        view?.addMessage(message: MessageModel(text: messageModel.text,
                                                   date: messageModel.date,
                                                   myMessage: true,
                                                   userName: "",
                                                   isSameUser: true))
    }
}
