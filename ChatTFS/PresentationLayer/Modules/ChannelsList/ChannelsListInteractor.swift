import Combine
import TFSChatTransport

protocol ChannelsListInteractorProtocol: AnyObject {
    func loadData()
    func createChannel(channelName: String)
    func deleteChannel(id: String)
    func getChannelImage(for channel: ChannelNetworkModel) -> UIImage
}

class ChannelsListInteractor: ChannelsListInteractorProtocol {
    
    // MARK: - Initialization
    
    init(chatService: ChatServiceProtocol, coreDataService: CoreDataServiceProtocol, dataManager: FileManagerServiceProtocol) {
        self.chatService = chatService
        self.coreDataService = coreDataService
        self.dataManager = dataManager
    }
    
    // MARK: - Public properties
    
    weak var presenter: ChannelsListPresenterProtocol?
    
    // MARK: - Private properties
    
    private var chatService: ChatServiceProtocol
    private var coreDataService: CoreDataServiceProtocol
    private var dataManager: FileManagerServiceProtocol
    private var handler: (([ChannelNetworkModel]) -> Void)?
    private var cacheChannels: [ChannelNetworkModel] = []
    private var networkChannels: [ChannelNetworkModel] = []
    
    // MARK: - Public methods
    
    func loadData() {
        
        handler = { [weak self] channels in
            self?.presenter?.dataChannels = channels
            self?.presenter?.dataUploaded()
            self?.networkChannels = []
        }
        
        loadFromCoreData()
        loadFromNetwork()
    }
    
    func createChannel(channelName: String) {
        let newChannel = chatService.createChannel(channelName: channelName)
        newChannel
            .sink { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.presenter?.interactorError()
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] channel in
                self?.presenter?.addChannel(channel: channel)
                self?.coreDataService.saveChannelsList(with: [channel])
            }
            .cancel()
    }
    
    func deleteChannel(id: String) {
        chatService.deleteChannel(id: id)
            .sink(receiveCompletion: { _ in
                self.coreDataService.deleteChannel(channelID: id)
            }, receiveValue: { _ in
            })
            .cancel()
    }
    
    func getChannelImage(for channel: ChannelNetworkModel) -> UIImage {
        dataManager.getChannelImage(for: channel)
    }
    
    // MARK: - Private methods
    
    private func loadFromCoreData() {
        let DBChannels = coreDataService.getChannelsFromDB()
        cacheChannels = DBChannels
        self.handler?(cacheChannels)
    }
    
    private func loadFromNetwork() {
        chatService.loadChannels()
            .sink { [weak self] result in
                switch result {
                case .finished:
                    self?.handler?(self?.networkChannels ?? [])
                case .failure(let error):
                    self?.presenter?.interactorError()
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] actualChannels in
                self?.compareChannelsModel(cacheChannels: self?.cacheChannels ?? [],
                                           networkChannels: actualChannels)
            }
            .cancel()
    }
    
    private func compareChannelsModel(cacheChannels: [ChannelNetworkModel], networkChannels: [ChannelNetworkModel]) {
        networkChannels.forEach { networkChannel in

            if !cacheChannels.contains(where: { networkChannel.id == $0.id }) {
                coreDataService.saveChannelsList(with: [ChannelNetworkModel(id: networkChannel.id,
                                                                 name: networkChannel.name,
                                                                 logoURL: networkChannel.logoURL,
                                                                 lastMessage: networkChannel.lastMessage,
                                                                 lastActivity: networkChannel.lastActivity)])
            }

            self.networkChannels.append(ChannelNetworkModel(id: networkChannel.id,
                                                   name: networkChannel.name,
                                                   logoURL: networkChannel.logoURL,
                                                   lastMessage: networkChannel.lastMessage,
                                                   lastActivity: networkChannel.lastActivity))
        }
        
        let cachedIDs = cacheChannels.map { $0.id }
        let networkIDs = networkChannels.map { $0.id }

        let deletedChannels = cachedIDs.filter { !networkIDs.contains($0) }

        for deletedChannel in deletedChannels {
            coreDataService.deleteChannel(channelID: deletedChannel)
        }

        self.networkChannels.sort(by: { $0.lastActivity ?? Date() < $1.lastActivity ?? Date() })
        self.cacheChannels.sort(by: { $0.lastActivity ?? Date() < $1.lastActivity ?? Date() })

        for (networkElement, cacheElement) in zip(networkChannels, cacheChannels) {
            if networkElement.lastActivity != cacheElement.lastActivity || networkElement.lastMessage != cacheElement.lastMessage {
                coreDataService.updateChannel(for: networkElement)
                }
        }

        self.cacheChannels = []
    }
}