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
    private let mainQueue = DispatchQueue.main
    private let background = DispatchQueue.global(qos: .userInteractive)
    
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
        
        var messages: [MessageModel] = []
        background.async { [weak self] in
            self?.messagesData?.forEach({ [weak self] message in
                
            if message.userID == self?.userID && message.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                
                messages.append(MessageModel(image: nil,
                                             text: message.text,
                                             date: message.date,
                                             myMessage: true,
                                             userName: message.userName,
                                             isSameUser: true,
                                             id: message.id))
                
                if message.text.isLink() {
                    self?.interactor.getImageForMessage(link: message.text) { result in
                        switch result {
                        case .success(let image):
                            guard let uuid = messages.first(where: { $0.id == message.id })?.uuid else {
                                return
                            }
                            self?.mainQueue.async { [weak self] in
                                self?.view?.updateImage(image: image, id: uuid)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
            } else if message.text.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                
                let isSameUser = {
                    if self?.currentUserID == message.userID {
                        return true
                    } else {
                        self?.currentUserID = message.userID
                        return false
                    }
                }()
                
                if message.text.isLink() {
                    self?.interactor.getImageForMessage(link: message.text) { result in
                        switch result {
                        case .success(let image):
                            guard let uuid = messages.first(where: { $0.id == message.id })?.uuid else {
                                return
                            }
                            self?.mainQueue.async { [weak self] in
                                self?.view?.updateImage(image: image, id: uuid)
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
                messages.append(MessageModel(image: nil,
                                             text: message.text,
                                             date: message.date,
                                             myMessage: false,
                                             userName: message.userName,
                                             isSameUser: isSameUser,
                                             id: message.id))
            }
        })
        
            guard let channelData = self?.channelData else {
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
            
            self?.mainQueue.async { [weak self] in
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
        background.async { [weak self] in
            let isMyMessage = { messageModel.userID == self?.userID }()
            let isSameUser = {
                if self?.currentUserID == messageModel.userID {
                    return true
                } else {
                    self?.currentUserID = messageModel.userID
                    return false
                }
            }()
            
            if messageModel.text.isLink() {
                self?.interactor.getImageForMessage(link: messageModel.text) { result in
                    switch result {
                    case .success(let image):
                        guard let uuid = self?.view?.messages.first(where: { $0.id == messageModel.id })?.uuid else {
                            return
                        }
                        self?.mainQueue.async { [weak self] in
                            self?.view?.updateImage(image: image, id: uuid)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
            
            self?.currentUserID = messageModel.userID
            self?.mainQueue.async { [weak self] in
                self?.view?.addMessage(message: MessageModel(image: nil,
                                                       text: messageModel.text,
                                                             date: messageModel.date,
                                                             myMessage: isMyMessage,
                                                             userName: messageModel.userName,
                                                             isSameUser: isSameUser,
                                                             id: messageModel.id))
            }
        }
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
