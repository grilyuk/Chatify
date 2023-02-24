//
//  ImagePickerController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 24.02.2023.
//

import UIKit

class ImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.allowsEditing = true
    }
}
