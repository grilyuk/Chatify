import UIKit
import TFSChatTransport

protocol ConvListPresenterProtocol: AnyObject {
    
    var router: RouterProtocol? {get set}
    var profile: ProfileModel? { get set }
    var channels: [ConversationListModel] { get set }
    var dataConversations: [Channel]? { get set }
    var handler: (([ConversationListModel]) -> Void)? { get set }
    
    func viewReady()
    func dataUploaded()
    func didTappedConversation(to conversation: String, navigationController: UINavigationController)
    func addChannel(channel: Channel)
    func createChannel(name: String)
    func interactorError()
}

class ConvListPresenter {
    
    // MARK: - Public
    
    weak var view: ConvListViewProtocol?
    var router: RouterProtocol?
    let interactor: ConvListInteractorProtocol
    var profile: ProfileModel?
    var channels: [ConversationListModel] = []
    var dataConversations: [Channel]?
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
        
        var channelsWithMessages: [ConversationListModel] = []
        var channelsWithoutMessages: [ConversationListModel] = []
        let channelsGroup = DispatchGroup()
        
        dataConversations?.forEach({ channel in
            
            var channelImage = UIImage.channelPlaceholder
            channelsGroup.enter()
            
            DispatchQueue.global().async {

                if let imageURL = URL(string: channel.logoURL ?? "") {
                    do {
                        let imageData = try Data(contentsOf: imageURL)
                        channelImage = UIImage(data: imageData) ?? UIImage()
                    } catch {
                        print(CustomError(description: "Error with Data from URL"))
                    }
                }
                    switch channel.lastMessage {
                    case nil:
                        channelsWithoutMessages.append(ConversationListModel(channelImage: channelImage,
                                                                             name: channel.name,
                                                                             message: channel.lastMessage,
                                                                             date: channel.lastActivity,
                                                                             isOnline: false,
                                                                             hasUnreadMessages: true,
                                                                             conversationID: channel.id))
                    default:
                        channelsWithMessages.append(ConversationListModel(channelImage: channelImage,
                                                                          name: channel.name,
                                                                          message: channel.lastMessage,
                                                                          date: channel.lastActivity,
                                                                          isOnline: false,
                                                                          hasUnreadMessages: true,
                                                                          conversationID: channel.id))
                    }

                    var sortedChannels = channelsWithMessages
                        .sorted { $0.date ?? Date() > $1.date ?? Date() }
                    sortedChannels.append(contentsOf: channelsWithoutMessages)
                
                    self.channels = sortedChannels
                channelsGroup.leave()
            }
        })
        
        handler = { [weak self] conversations in
            self?.view?.conversations = conversations
            self?.view?.showMain()
        }
        
        channelsGroup.notify(queue: .main) { [weak self] in
            self?.handler?(self?.channels ?? [])
        }
    }
    
    func didTappedConversation(to conversation: String, navigationController: UINavigationController) {
        router?.showConversation(conversation: conversation, navigationController: navigationController)
    }
    
    func createChannel(name: String) {
        interactor.createChannel(channelName: name)
    }
    
    func addChannel(channel: Channel) {
        let channelImage = UIImage.channelPlaceholder
        let channelModel = ConversationListModel(channelImage: channelImage,
                                                 name: channel.name,
                                                 message: channel.lastMessage,
                                                 date: channel.lastActivity,
                                                 isOnline: false,
                                                 hasUnreadMessages: true,
                                                 conversationID: channel.id)
        view?.addChannel(channel: channelModel)
    }
    
    func interactorError() {
        view?.showAlert()
    }
}
