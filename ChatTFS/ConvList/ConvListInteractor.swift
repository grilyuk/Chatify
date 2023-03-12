//
//  MainInteractor.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol ConvListInteractorProtocol: AnyObject {
    func loadData()

}

class ConvListInteractor: ConvListInteractorProtocol {
    var presenter: ConvListPresenterProtocol?
    
    func loadData() {
        presenter?.dataUploaded()
        guard let presenter = presenter as? ConvListPresenter else { return }
        let profile = ProfileModel(profileImage: nil,
                                   fullName: "Grigoriy Danilyuk",
                                   statusText: "Almost iOS Developer \nSaint-Petersburg, Russia")
        presenter.handler?(profile)
        
    }
}
