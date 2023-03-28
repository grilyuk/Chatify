import UIKit
import Combine

protocol ProfileInteractorProtocol: AnyObject {
    func loadData()
    func pushData(profile: ProfileModel)
}

class ProfileInteractor: ProfileInteractorProtocol {
    
    //MARK: - Initializer
    init(profilePublisher: AnyPublisher<Data, Error>, dataManager: DataManagerProtocol) {
        self.profilePublisher = profilePublisher
        self.dataManager = dataManager
    }
    
    //MARK: - Public
    weak var presenter: ProfilePresenterProtocol?
    weak var dataManager: DataManagerProtocol?
    
    //MARK: - Private
    private var handler: ((ProfileModel) -> Void)?
    private var profilePublisher: AnyPublisher<Data, Error>
    private var profileRequest: Cancellable?

    //MARK: - Methods
    func loadData() {
        
        presenter?.dataUploaded()
        
//        handler = { [weak self] profile in
//            self?.presenter?.profile = profile
//            self?.presenter?.dataUploaded()
//            self?.profileRequest?.cancel()
//        }
        
//        profileRequest = profilePublisher
//            .subscribe(on: DispatchQueue.global())
//            .receive(on: DispatchQueue.main)
//            .handleEvents(receiveCancel: { print("Cancel sub in ProfileInteractor") })
//            .decode(type: ProfileModel.self, decoder: JSONDecoder())
//            .catch({_ in Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))})
//            .sink(receiveValue: { [weak self] profile in
//                self?.handler?(profile)
//            })
    }
    
    func publisher () {
        profileRequest = profilePublisher
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCancel: { print("Cancel sub in ProfileInteractor") })
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({_ in Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))})
            .sink(receiveValue: { [weak self] profile in
                self?.handler?(profile)
            })
    }
    
    func pushData(profile: ProfileModel) {
        profileRequest = dataManager?.writeProfilePublisher(profile: profile)
            .subscribe(on: DispatchQueue.global())
            .encode(encoder: JSONEncoder())
            .map({ data in
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let pathWithFileName = documentDirectory.appendingPathComponent("profileData.json")
                    try? data.write(to: pathWithFileName)
                    return true
                }
                return false
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] _ in
                self?.profileRequest?.cancel()
            }, receiveValue: { [weak self] result in
                self?.presenter?.dataUploaded()
            })
    }
}
