import UIKit
import Combine
import TFSChatTransport

protocol ConvListInteractorProtocol: AnyObject {
    func loadData()
    func createChannel(channelName: String)
}

class ConvListInteractor: ConvListInteractorProtocol {
    
    // MARK: - Initialization
    
    init(dataManager: DataManagerProtocol, chatService: ChatService) {
        self.dataManager = dataManager
        self.chatService = chatService
    }
    
    // MARK: - Public
    
    weak var presenter: ConvListPresenterProtocol?
    var dataManager: DataManagerProtocol?
    var chatService: ChatService?
    
    // MARK: - Private
    
    private var handler: (([Channel]) -> Void)?
    private var dataRequest: Cancellable?
    private var channelsRequest: Cancellable?
    
    // MARK: - Methods
    
    func loadData() {

        handler = { [weak self] conversations in
            self?.presenter?.dataConverstions = conversations
            self?.presenter?.dataUploaded()
            self?.channelsRequest?.cancel()
        }
        
        channelsRequest = chatService?.loadChannels()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.presenter?.interactorError()
            }, receiveValue: { [weak self] channels in
                self?.handler?(channels)
            })
    }
    
    func createChannel(channelName: String) {
        channelsRequest = chatService?.createChannel(name: channelName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.presenter?.interactorError()
                self?.channelsRequest?.cancel()
            }, receiveValue: { [weak self] channel in
                self?.presenter?.addChannel(channel: channel)
            })
    }
}
