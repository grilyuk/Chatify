import UIKit
import TFSChatTransport

protocol ChannelsListPresenterProtocol: AnyObject {
    var router: RouterProtocol? { get set }
    var dataChannels: [ChannelNetworkModel]? { get set }
    
    func viewReady()
    func dataUploaded()
    func didTappedChannel(to channel: String, navigationController: UINavigationController)
    func addChannel(channel: ChannelNetworkModel)
    func createChannel(name: String)
    func deleteChannel(id: String)
    func deleteFromView(channelID: String)
    func interactorError()
    func updateChannel(channel: ChannelNetworkModel)
    func subscribeToSSE()
    func unsubscribeFromSSE()
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
    private let mainQueue = DispatchQueue.main
    private let backgroundQueue = DispatchQueue.global()
    
    // MARK: - Initialization
    
    init(interactor: ChannelsListInteractorProtocol) {
        self.interactor = interactor
    }
    
    // MARK: - Public methods
    
    func viewReady() {
        interactor.loadData()
    }
    
    func dataUploaded() {
        
        handler = { [weak self] sortedChannels in
            self?.view?.channels = sortedChannels
            self?.view?.showChannelsList()
        }
        
        backgroundQueue.async { [weak self] in
            guard let self else {
                return
            }
            
            self.channels = self.dataChannels?.map({ channel in
                let channelLogo: UIImage = self.interactor.getChannelImage(for: channel)
                return ChannelModel(channelImage: channelLogo,
                                    name: channel.name,
                                    message: channel.lastMessage,
                                    date: channel.lastActivity,
                                    isOnline: false,
                                    hasUnreadMessages: false,
                                    channelID: channel.id)
            }) ?? []
            
            self.channels.sort { $0.date ?? Date(timeIntervalSince1970: 0) > $1.date ?? Date(timeIntervalSince1970: 0) }
            
            self.mainQueue.async { [weak self] in
                self?.handler?(self?.channels ?? [])
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
    
    func deleteFromView(channelID: String) {
        guard let actualChannel = channels.first(where: { $0.channelID == channelID })
        else {
            return
        }
        view?.deleteChannel(channel: actualChannel)
    }
    
    func addChannel(channel: ChannelNetworkModel) {
        backgroundQueue.async { [weak self] in
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
            self.mainQueue.async { [weak self] in
                self?.channels.append(channelModel)
                self?.view?.addChannel(channel: channelModel)
            }
        }
    }
    
    func interactorError() {
        view?.showAlert()
    }
    
    func updateChannel(channel: ChannelNetworkModel) {
        guard var actualChannel = channels.first(where: { $0.channelID == channel.id })
        else {
            return
        }
        actualChannel.date = channel.lastActivity
        actualChannel.message = channel.lastMessage
        view?.updateChannel(channel: actualChannel)
    }
    
    func subscribeToSSE() {
        interactor.subscribeToSSE()
    }
    
    func unsubscribeFromSSE() {
        interactor.unsubscribeFromSSE()
    }
}
