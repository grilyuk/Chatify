import UIKit
import Combine

protocol ConvListInteractorProtocol: AnyObject {
    func loadData()
}

class ConvListInteractor: ConvListInteractorProtocol {

    //MARK: - Initializer
    init(profilePublisher: AnyPublisher<Data, Error>, dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
        self.profilePublisher = profilePublisher
    }
    
    //MARK: - Public
    weak var presenter: ConvListPresenterProtocol?
    var dataManager: DataManagerProtocol?
    
    //MARK: - Private
    private var handler: (([ConversationListModel]) -> Void)?
    private var profilePublisher: AnyPublisher<Data, Error>
    private var profileRequest: Cancellable?
    
    //MARK: - Methods
    func loadData() {
        let users = [
            ConversationListModel(name: "Charis Clay",
                                  message: "I think Houdini did something like this once! Why, if I recall correctly, he was out of the hospital",
                                  date: Date(timeIntervalSinceNow: -100000),
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Lacey Finch",
                                  message: nil,
                                  date: nil,
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Norma Carver",
                                  message: nil,
                                  date: nil,
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Dawson Suarez",
                                  message: "Привет",
                                  date: Date(timeIntervalSinceNow: -54252),
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Aminah Burch",
                                  message: "How are you?",
                                  date: Date(timeIntervalSinceNow: -4235),
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Rodney Sharp",
                                  message: "Go to shop",
                                  date: Date(timeIntervalSinceNow: -3242),
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Erin Duke",
                                  message: nil,
                                  date: nil,
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Mehmet Matthams",
                                  message: nil,
                                  date: nil,
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Malik Rios",
                                  message: "Я с тобой не разговариваю...",
                                  date: Date(timeIntervalSince1970: 0),
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Samantha Erickson",
                                  message: "Ладно",
                                  date: Date(timeIntervalSinceNow: -124151513),
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Sid Terry",
                                  message: "Hello",
                                  date: Date(timeIntervalSinceReferenceDate: 4525346),
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Lochlan Alexander",
                                  message: nil,
                                  date: nil,
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Ishaan Matthews",
                                  message: "Hello",
                                  date: Date(timeIntervalSinceNow: -5325),
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Jazmin Clayton",
                                  message: "Я в своём познании настолько преисполнился, что как будто бы уже 100 триллионов миллиардов лет проживаю",
                                  date: Date(timeIntervalSinceReferenceDate: 1352533),
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Hamish Barker",
                                  message: "Hello",
                                  date: Date(),
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Kezia Finley",
                                  message: "Прив че дел??",
                                  date: Date(timeIntervalSinceNow: -9932),
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Sylvia Cooper",
                                  message: "Предлагаем работу 300кк/нс нужно всего лишь быть",
                                  date: Date(timeIntervalSinceNow: -35551),
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Erica Tate",
                                  message: nil,
                                  date: nil,
                                  isOnline: false,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Liana Fitzgerald",
                                  message: nil,
                                  date: nil,
                                  isOnline: true,
                                  hasUnreadMessages: nil),
            ConversationListModel(name: "Aiza Fischer",
                                  message: nil,
                                  date: nil,
                                  isOnline: false,
                                  hasUnreadMessages: nil)
        ]

        handler = { [weak self] users in
            self?.presenter?.users = users
            self?.presenter?.dataUploaded()
            self?.profileRequest?.cancel()
        }
        
        profileRequest = profilePublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCancel: { print("Cancel sub in ConvListInteractor") })
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({_ in Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))})
            .sink(receiveValue: { [weak self] profile in
                self?.dataManager?.currentProfile.send(profile)
                self?.handler?(users)
            })
    }
}
