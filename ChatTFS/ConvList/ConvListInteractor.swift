//
//  MainInteractor.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol MainInteractorProtocol: AnyObject {
    func loadData()

}

class MainInteractor: MainInteractorProtocol {
    var presenter: MainPresenterProtocol?
    
    func loadData() {
        presenter?.profile = ProfileModel(profileImage: nil,
                                          fullName: "Grigoriy Danilyuk",
                                          statusText: "Almost iOS Developer \nSaint-Petersburg, Russia")
        presenter?.dataUploaded()
    }
    
}
