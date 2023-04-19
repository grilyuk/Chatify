import UIKit
import TFSChatTransport
import Combine

protocol ChannelPresenterProtocol: AnyObject {
    
    var handler: ((ChannelModel, [MessageModel]) -> Void)? { get set }
    var messagesData: [MessageNetworkModel]? { get set }
    var channelData: ChannelNetworkModel? { get set }
    
    func viewReady()
    func dataUploaded()
    func uploadMessage(messageModel: Message)
    func createMessage(messageText: String?)
}

class ChannelPresenter {
    
    // MARK: - Public
    
    weak var view: ChannelViewProtocol?
    let router: RouterProtocol?
    let interactor: ChannelInteractorProtocol
    var messagesData: [MessageNetworkModel]?
    var channelData: ChannelNetworkModel?
    var handler: ((ChannelModel, [MessageModel]) -> Void)?
    
    // MARK: - Private properties
    
    var dataManager: FileManagerServiceProtocol
    private var userDataRequest: Cancellable?
    private var userID: String
    private var userName: String?
    
    // MARK: - Initialization
    
    init(router: RouterProtocol, interactor: ChannelInteractorProtocol, dataManager: FileManagerServiceProtocol) {
        self.router = router
        self.interactor = interactor
        self.dataManager = dataManager
        self.userID = dataManager.userId
    }
}

// MARK: - ChannelPresenter + ChannelPresenterProtocol

extension ChannelPresenter: ChannelPresenterProtocol {
    
    // MARK: - Methods

    func viewReady() {

        userDataRequest = dataManager.readProfilePublisher()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({_ in
                Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))
            })
            .sink(receiveValue: { [weak self] profile in
                self?.userName = profile.fullName
            })
                    
        interactor.loadData()
    }
    
    func dataUploaded() {
        
        handler = { [weak self] channel, messages in
            self?.view?.messages = messages
            self?.view?.showChannel(channel: channel)
        }
        
        var currentUserID = ""
        var messages: [MessageModel] = []
        messagesData?.forEach({ [weak self] message in
            if message.userID == self?.userID && message.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                messages.append(MessageModel(text: message.text,
                                                 date: message.date,
                                                 myMessage: true,
                                                 userName: message.userName,
                                                 isSameUser: true))
                
            } else if message.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
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
            guard
                let channelData = self?.channelData
            else {
                return
            }
            
            let channelImage: UIImage = self?.dataManager.getChannelImage(for: channelData) ?? UIImage()
            
            let channel = ChannelModel(channelImage: channelImage,
                                       name: channelData.name,
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
    
    func createMessage(messageText: String?) {
        if messageText != nil && messageText != "" {
            guard
                let userName,
                let messageText
            else {
                return
            }
            interactor.createMessageData(messageText: messageText,
                                         userID: userID,
                                         userName: userName)
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
