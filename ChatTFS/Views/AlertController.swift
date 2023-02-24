//
//  AlertController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 24.02.2023.
//

import UIKit

class AlertController: UIAlertController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var vc: UIViewController?
    let pickerController = ImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addActions()
    }
    
    private func addActions() {
        
        self.addAction(UIAlertAction(title: "Сделать фото", style: .default) { UIAlertAction in
            self.pickerController.sourceType = .camera
            self.vc?.present(self.pickerController, animated: true, completion: nil)
        })

        self.addAction(UIAlertAction(title: "Галерея", style: .default) { UIAlertAction in
            self.pickerController.sourceType = .photoLibrary
            self.vc?.present(self.pickerController, animated: true, completion: nil)
        })
        
        self.addAction(UIAlertAction(title: "Отмена", style: .cancel) { UIAlertAction in
            
        })
    }
}
