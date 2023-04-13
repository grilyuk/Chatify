import UIKit
import TFSChatTransport

protocol ConvListPresenterProtocol: AnyObject {
    var router: RouterProtocol? {get set}
    var profile: ProfileModel? { get set }
    var channels: [ConversationListModel] { get set }
    var dataConverstions: [Channel]? { get set }
    func viewReady()
    func dataUploaded()
    func didTappedConversation(to conversation: String, navigationController: UINavigationController)
    func addChannel(channel: Channel)
    func createChannel(name: String)
    func interactorError()
    var handler: (([ConversationListModel]) -> Void)? { get set }
}

class ConvListPresenter {
    
    // MARK: - Public
    
    weak var view: ConvListViewProtocol?
    var router: RouterProtocol?
    let interactor: ConvListInteractorProtocol
    var profile: ProfileModel?
    var channels: [ConversationListModel] = []
    var dataConverstions: [Channel]?
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
        dataConverstions?.forEach({ channel in
            DispatchQueue.global().async {
                
                var channelImage = UIImage.channelPlaceholder
                
                if let imageURL = URL(string: channel.logoURL ?? "") {
                    do {
                        let imageData = try Data(contentsOf: imageURL)
                        channelImage = UIImage(data: imageData) ?? UIImage()
                    } catch {
                        print(CustomError(description: "Error with Data from URL"))
                    }
                }
                
                DispatchQueue.main.async {
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
                    
                    self.handler = { [weak self] conversations in
                        self?.view?.conversations = conversations
                        self?.view?.showMain()
                    }
                    self.handler?(self.channels)
                }
            }
        })
        view?.pullToRefresh.endRefreshing()
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
