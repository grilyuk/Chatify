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

    func loadData() {
        presenter?.dataUploaded()
    }
}
