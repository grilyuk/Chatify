import UIKit

class ChooseSourceAlertController: UIAlertController {

    // MARK: - Properties
    
    weak var profileVC: ProfileViewProtocol?
    weak var router: RouterProtocol?
    var photoPickerController: PhotoPickerController?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addActions()
    }

    // MARK: - Private methods
    
    private func addActions() {
        addAction(UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
            self?.photoPickerController = PhotoPickerController()
            self?.photoPickerController?.sourceType = .camera
            guard let profileVC = self?.profileVC as? UIViewController,
                  let photoPickerController = self?.photoPickerController
            else {
                return
            }
            profileVC.present(photoPickerController, animated: true) {
                photoPickerController.profileVC = self?.profileVC
            }
        })

        addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self] _ in
            self?.photoPickerController = PhotoPickerController()
            self?.photoPickerController?.sourceType = .photoLibrary
            guard let profileVC = self?.profileVC as? UIViewController,
                  let photoPickerController = self?.photoPickerController
            else {
                return
            }
            profileVC.present(photoPickerController, animated: true) {
                photoPickerController.profileVC = self?.profileVC
            }
        })
        
        addAction(UIAlertAction(title: "Загрузить", style: .default) { [weak self] _ in
            guard let profileVC = self?.profileVC as? ProfileViewProtocol
            else {
                return
            }
            profileVC.showNetworkImages()
        })

        addAction(UIAlertAction(title: "Отмена", style: .cancel))
    }
}
