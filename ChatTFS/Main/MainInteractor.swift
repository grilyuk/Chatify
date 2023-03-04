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
    weak var presenter: MainPresenterProtocol?
    
    func loadData() {
        presenter?.dataUploaded()
    }
}
