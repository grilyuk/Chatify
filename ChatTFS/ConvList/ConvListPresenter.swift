import UIKit
import TFSChatTransport

protocol ConvListPresenterProtocol: AnyObject {
    
    var router: RouterProtocol? {get set}
    var profile: ProfileModel? { get set }
    var dataChannels: [Channel]? { get set }
    var handler: (([ChannelModel]) -> Void)? { get set }
    
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
    var dataChannels: [Channel]?
    var handler: (([ChannelModel]) -> Void)?
    
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
        
        handler = { sortedChannels in
            self.view?.conversations = sortedChannels
            self.view?.showMain()
        }
        var channels: [ChannelModel] = []
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.dataChannels?.forEach({ dataChannel in
                
                let placeholderImage = UIImage.channelPlaceholder
                var channelLogo: UIImage
                
                if let urlString = dataChannel.logoURL,
                   let logoURL = URL(string: urlString) {
                    do {
                        let imageData = try Data(contentsOf: logoURL)
                        channelLogo = UIImage(data: imageData) ?? UIImage()
                    } catch {
                        print(error)
                        channelLogo = placeholderImage
                    }
                } else {
                    channelLogo = placeholderImage
                }

                channels.append(ChannelModel(channelImage: channelLogo,
                                                      name: dataChannel.name,
                                                      message: dataChannel.lastMessage,
                                                      date: dataChannel.lastActivity,
                                                      isOnline: false,
                                                      hasUnreadMessages: false,
                                                      conversationID: dataChannel.id))
                
            })
            
            DispatchQueue.main.async { [weak self] in
                channels.sort { $0.date ?? Date() > $1.date ?? Date() }
                self?.handler?(channels)
            }
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
        let channelModel = ChannelModel(channelImage: channelImage,
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
