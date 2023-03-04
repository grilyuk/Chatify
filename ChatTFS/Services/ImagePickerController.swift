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
    weak var vc: ProfileViewController?

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.allowsEditing = true
    }

    //MARK: Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePicked = image
            guard let vc else { return }
            vc.profileImageView.image = imagePicked
            vc.viewDidLayoutSubviews()
            dismiss(animated: true)
        }
    }
}
