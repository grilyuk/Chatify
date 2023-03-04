//
//  AlertController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 24.02.2023.
//

import UIKit

class AlertController: UIAlertController {

    //MARK: Properties
    var vc: ProfileViewController?
    var pickerController: ImagePickerController?

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.pickerController = ImagePickerController()
        }
        addActions()
    }

    //MARK: Methods
    private func addActions() {
        self.addAction(UIAlertAction(title: "Сделать фото", style: .default) { _ in
            guard let picker = self.pickerController else {return}
            self.pickerController?.sourceType = .camera
            self.vc?.present(picker, animated: true) {
                self.pickerController?.vc = self.vc
            }
        })

        self.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
            guard let picker = self.pickerController else {return}
            self.pickerController?.sourceType = .photoLibrary
            self.vc?.present(picker, animated: true) {
                self.pickerController?.vc = self.vc
            }
        })

        self.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    }
}
