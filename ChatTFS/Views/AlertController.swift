//
//  AlertController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 24.02.2023.
//

import UIKit

class AlertController: UIAlertController {
    
    var vc: UIViewController?
    private let pickerController = ImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addActions()
    }
    
    private func addActions() {
        self.addAction(UIAlertAction(title: "Сделать фото", style: .default) { _ in
            self.pickerController.sourceType = .camera
            self.vc?.present(self.pickerController, animated: true) {
                self.pickerController.vc = self.vc as? ProfileViewController
            }
        })

        self.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
            self.pickerController.sourceType = .photoLibrary
            self.vc?.present(self.pickerController, animated: true) {
                self.pickerController.vc = self.vc as? ProfileViewController
            }
        })
        
        self.addAction(UIAlertAction(title: "Отмена", style: .cancel))
    }
}
