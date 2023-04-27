import UIKit
import TFSChatTransport
import Combine

protocol ChannelPresenterProtocol: AnyObject {
    var handler: ((ChannelModel, [MessageModel]) -> Void)? { get set }
    var messagesData: [MessageNetworkModel]? { get set }
    var channelData: ChannelNetworkModel? { get set }
    
    func viewReady()
    func dataUploaded()
    func uploadMessage(messageModel: MessageNetworkModel)
    func createMessage(messageText: String?)
    func subscribeToSSE()
    func unsubscribeFromSSE()
    func showNetworkImages(navigationController: UINavigationController, vc: UIViewController)
}

class ChannelPresenter {
    
    // MARK: - Public properties
    
    weak var view: ChannelViewProtocol?
    let router: RouterProtocol?
    let interactor: ChannelInteractorProtocol
    var messagesData: [MessageNetworkModel]?
    var channelData: ChannelNetworkModel?
    var handler: ((ChannelModel, [MessageModel]) -> Void)?
    
    // MARK: - Private properties

    private var userID: String?
    private var userName: String?
    var currentUserID = ""
    
    // MARK: - Initialization
    
    init(router: RouterProtocol, interactor: ChannelInteractorProtocol) {
        self.router = router
        self.interactor = interactor
    }
}

// MARK: - ChannelPresenter + ChannelPresenterProtocol

extension ChannelPresenter: ChannelPresenterProtocol {
    
    // MARK: - Methods

    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        
        self.userName = interactor.userName
        self.userID = interactor.userID
        
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
            
            let channelImage: UIImage = self?.interactor.getChannelImage(for: channelData) ?? UIImage()
            
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
                let messageText,
                let userID
            else {
                return
            }
            interactor.createMessage(messageText: messageText,
                                         userID: userID,
                                         userName: userName)
        }
    }
    
    func uploadMessage(messageModel: MessageNetworkModel) {
        let isMyMessage = { messageModel.userID == userID }()
        let isSameUser = {
            if currentUserID == messageModel.userID {
                return true
            } else {
                currentUserID = messageModel.userID
                return false
            }
        }()
        currentUserID = messageModel.userID
        view?.addMessage(message: MessageModel(text: messageModel.text,
                                                   date: messageModel.date,
                                                   myMessage: isMyMessage,
                                               userName: messageModel.userName,
                                                   isSameUser: isSameUser))
    }
    
    func subscribeToSSE() {
        interactor.subscribeToSSE()
    }
    
    func unsubscribeFromSSE() {
        interactor.unsubscribeFromSSE()
    }
    
    func showNetworkImages(navigationController: UINavigationController, vc: UIViewController) {
        router?.showNetworkImages(navigationController: navigationController, vc: vc)
    }
}
