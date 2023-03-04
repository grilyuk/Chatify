//
//  ProfileInteractor.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 26.02.2023.
//

import UIKit

protocol ProfileInteractorProtocol: AnyObject {
    func loadData()
}

class ProfileInteractor: ProfileInteractorProtocol {
    weak var presenter: ProfilePresenterProtocol?
    var profile: ProfileModel

    init(profile: ProfileModel) {
        self.profile = profile
    }

    func loadData() {
// здесь еще можно что то поменять в профиле
        presenter?.didLoad(data: profile )
    }
}