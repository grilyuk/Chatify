//
//  MainInteractor.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol MainInteractorProtocol: AnyObject {
    func loadData()
    var profile: ProfileModel? { get }
}

class MainInteractor: MainInteractorProtocol {
    weak var presenter: MainPresenterProtocol?
    var profile: ProfileModel? = nil

    func loadData() {
//здесь предполагается загрузка данных из кэша/сети, после чего, полученные данные пойдут дальше
        self.profile = ProfileModel(profileImage: nil,
                                    fullName: "Grigoriy Danilyuk",
                                    statusText: "Almost iOS Developer \nSaint-Petersburg, Russia")
        presenter?.dataDidLoaded()
    }
}
