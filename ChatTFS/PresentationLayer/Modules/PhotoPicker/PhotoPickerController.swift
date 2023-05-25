import UIKit

class PhotoPickerController: UIImagePickerController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    // MARK: - Properties
    
    var imagePicked: UIImage?
    weak var profileVC: EditProfileViewController?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.allowsEditing = true
    }

    // MARK: - Private methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePicked = image
            guard let profileVC else {
                return
            }
            profileVC.profilePhoto.image = imagePicked
            dismiss(animated: true)
        }
    }
}
