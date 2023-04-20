import UIKit
import Combine

protocol ProfileInteractorProtocol: AnyObject {
    func loadData()
    func updateData(profile: ProfileModel)
}

class ProfileInteractor: ProfileInteractorProtocol {
    
    // MARK: - Initialization
    
    init(dataManager: FileManagerServiceProtocol) {
        self.dataManager = dataManager
    }
    
    // MARK: - Public
    
    weak var presenter: ProfilePresenterProtocol?
    
    // MARK: - Private
    
    private var handler: ((ProfileModel) -> Void)?
    private var dataManager: FileManagerServiceProtocol

    // MARK: - Methods
    
    func loadData() {
        
        handler = { [weak self] profile in
            self?.presenter?.profile = profile
            self?.presenter?.dataUploaded()
        }
        
        dataManager.readProfilePublisher()
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .decode(type: ProfileModel.self, decoder: JSONDecoder())
            .catch({_ in
                Just(ProfileModel(fullName: nil, statusText: nil, profileImageData: nil))})
                .sink(receiveValue: { [weak self] profile in
                    self?.dataManager.currentProfile.send(profile)
                    self?.handler?(profile)
                })
                    .cancel()
    }
    
    func updateData(profile: ProfileModel) {
        dataManager.writeProfilePublisher(profile: profile)
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .encode(encoder: JSONEncoder())
            .map({ data in
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let pathWithFileName = documentDirectory.appendingPathComponent("profileData.json")
                    try? data.write(to: pathWithFileName)
                    return true
                }
                return false
            })
            .sink(receiveCompletion: { _ in
            }, receiveValue: { [weak self] result in
                switch result {
                case true:
                    self?.dataManager.currentProfile.send(profile)
                    self?.presenter?.dataUploaded()
                case false:
                    break
                }
            })
            .cancel()
    }
}
