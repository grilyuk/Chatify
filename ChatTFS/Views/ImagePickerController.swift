//
//  ImagePickerController.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 24.02.2023.
//

import UIKit

class ImagePickerController: UIImagePickerController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    //MARK: Properties
    var imagePicked: UIImage?
    var vc: ProfileViewController?

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.allowsEditing = true
    }

    //MARK: Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imagePicked = image
            guard vc != nil else { return }
            vc?.profileImageView.image = imagePicked
            vc?.viewDidLayoutSubviews()
            self.dismiss(animated: true)
        }
    }
}
