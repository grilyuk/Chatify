import UIKit
import Combine
import TFSChatTransport

protocol ConvListInteractorProtocol: AnyObject {
    func loadData()
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
    
    private var handler: (([ConversationListModel]) -> Void)?
    private var dataRequest: Cancellable?
    private var channelsRequest: Cancellable?
    
    // MARK: - Methods
    
    func loadData() {
        let conversations = [
            ConversationListModel(name: "Charis Clay",
                                  message: "I think Houdini did something like this once! Why, if I recall correctly, he was out of the hospital",
                                  date: Date(timeIntervalSinceNow: -100000),
                                  isOnline: true,
                                  hasUnreadMessages: nil)
        ]

        handler = { [weak self] conversations in
            self?.presenter?.users = conversations
            self?.presenter?.dataUploaded()
            self?.dataRequest?.cancel()
        }
        
        dataRequest = dataManager?.readProfilePublisher()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCancel: { print("Cancel sub in ConvListInteractor") })
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({ _ in
                Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))})
            .sink(receiveValue: { [weak self] profile in
                self?.dataManager?.currentProfile.send(profile)
                self?.handler?(conversations)
            })
    }
    
    func loadChannels() {
        channelsRequest = chatService?.loadChannels()
            .sink(receiveCompletion: { _ in
            }, receiveValue: { channel in
                print(channel)
            })
    }
    
    func createChannel(name: String) {
        
    }
}
