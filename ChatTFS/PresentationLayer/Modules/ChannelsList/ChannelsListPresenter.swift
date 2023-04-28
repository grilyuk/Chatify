import UIKit
import TFSChatTransport

protocol ChannelsListPresenterProtocol: AnyObject {
    var router: RouterProtocol? { get set }
    var dataChannels: [ChannelNetworkModel]? { get set }
    var handler: (([ChannelModel]) -> Void)? { get set }
    
    func viewReady()
    func dataUploaded()
    func didTappedChannel(to channel: String, navigationController: UINavigationController)
    func addChannel(channel: ChannelNetworkModel)
    func createChannel(name: String)
    func deleteChannel(id: String)
    func interactorError()
}

class ChannelsListPresenter: ChannelsListPresenterProtocol {
    
    // MARK: - Public properties
    
    weak var view: ChannelsListViewProtocol?
    var router: RouterProtocol?
    var dataChannels: [ChannelNetworkModel]?
    var handler: (([ChannelModel]) -> Void)?
    var channels: [ChannelModel] = []
    
    // MARK: - Private properties
    
    private var interactor: ChannelsListInteractorProtocol
    
    // MARK: - Initialization
    
    init(interactor: ChannelsListInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Public methods
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        
        var channels: [ChannelModel] = []
        
        handler = { [weak self] sortedChannels in
            self?.view?.channels = sortedChannels
            self?.view?.showChannelsList()
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            
            guard let self
            else {
                return
            }
            
            self.dataChannels?.forEach({ dataChannel in
                let channelLogo: UIImage = self.interactor.getChannelImage(for: dataChannel)
                
                if dataChannel.lastMessage == nil {
                    channels.append(ChannelModel(channelImage: channelLogo,
                                                 name: dataChannel.name,
                                                 message: dataChannel.lastMessage,
                                                 date: dataChannel.lastActivity,
                                                 isOnline: false,
                                                 hasUnreadMessages: false,
                                                 channelID: dataChannel.id))
                } else {
                    channels.append(ChannelModel(channelImage: channelLogo,
                                                 name: dataChannel.name,
                                                 message: dataChannel.lastMessage,
                                                 date: dataChannel.lastActivity,
                                                 isOnline: false,
                                                 hasUnreadMessages: false,
                                                 channelID: dataChannel.id))
                }
            })
            
            DispatchQueue.main.async { [weak self] in
                channels.sort { $0.date ?? Date(timeIntervalSince1970: 0) > $1.date ?? Date(timeIntervalSince1970: 0) }
                self?.handler?(channels)
            }
        }
    }
    
    func didTappedChannel(to channel: String, navigationController: UINavigationController) {
        router?.showChannel(channel: channel, navigationController: navigationController)
    }
    
    func createChannel(name: String) {
        interactor.createChannel(channelName: name)
    }
    
    func deleteChannel(id: String) {
        interactor.deleteChannel(id: id)
    }
    
    func addChannel(channel: ChannelNetworkModel) {
        DispatchQueue.global().async { [weak self] in
            guard let self
            else {
                return
            }
            let channelImage = self.interactor.getChannelImage(for: channel)
            let channelModel = ChannelModel(channelImage: channelImage,
                                            name: channel.name,
                                            message: channel.lastMessage,
                                            date: channel.lastActivity,
                                            isOnline: false,
                                            hasUnreadMessages: true,
                                            channelID: channel.id)
            DispatchQueue.main.async { [weak self] in
                self?.view?.addChannel(channel: channelModel)
            }
        }
    }
    
    func interactorError() {
        view?.showAlert()
    }
    
}
