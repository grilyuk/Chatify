import UIKit
import TFSChatTransport

protocol ChannelsListPresenterProtocol: AnyObject {
    
    var router: RouterProtocol? {get set}
    var profile: ProfileModel? { get set }
    var dataChannels: [ChannelNetworkModel]? { get set }
    var handler: (([ChannelModel]) -> Void)? { get set }
    
    func viewReady()
    func dataUploaded()
    func didTappedChannel(to channel: String, navigationController: UINavigationController)
    func addChannel(channel: ChannelNetworkModel)
    func createChannel(name: String)
    func interactorError()
}

class ChannelsListPresenter {
    
    // MARK: - Public
    
    weak var view: ChannelsListViewProtocol?
    weak var dataManager: DataManagerProtocol?
    var router: RouterProtocol?
    let interactor: ChannelsListInteractorProtocol
    var profile: ProfileModel?
    var dataChannels: [ChannelNetworkModel]?
    var handler: (([ChannelModel]) -> Void)?
    var newChannelsHandler: (([ChannelModel]) -> Void)?
    var channels: [ChannelModel] = []
    
    // MARK: - Initialization
    
    init(interactor: ChannelsListInteractorProtocol, dataManager: DataManagerProtocol) {
        self.interactor = interactor
        self.dataManager = dataManager
    }
}

// MARK: - ChannelsListPresenter + ChannelsListPresenterProtocol

extension ChannelsListPresenter: ChannelsListPresenterProtocol {
    
    // MARK: - Methods
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        
        var channels: [ChannelModel] = []
        
        handler = { [weak self] sortedChannels in
            self?.view?.channels = sortedChannels
            self?.view?.showChannelsList()
        }
        
        newChannelsHandler = { [weak self] newChannels in
            self?.view?.appendNewChannel(channels: newChannels)
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.dataChannels?.forEach({ dataChannel in
                
                guard let dataManager = self?.dataManager as? DataManager else {
                    return
                }
                let channelLogo: UIImage = dataManager.getChannelImage(for: dataChannel) 
                
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
    
    func addChannel(channel: ChannelNetworkModel) {
        DispatchQueue.global().async { [weak self] in
            let channelImage = self?.dataManager?.getChannelImage(for: channel)
            let channelModel = ChannelModel(channelImage: channelImage ?? UIImage(),
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
