import UIKit

class AlertController: UIAlertController {

    //MARK: - Properties
    weak var vc: UIViewController?
    private var pickerController: ImagePickerController?

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerController = ImagePickerController()
        addActions()
    }

    //MARK: - Methods
    private func addActions() {
        addAction(UIAlertAction(title: "Сделать фото", style: .default) { _ in
            guard let picker = self.pickerController else {return}
            self.pickerController?.sourceType = .camera
            self.vc?.present(picker, animated: true) {
                self.pickerController?.vc = self.vc as? ProfileViewController
            }
        })

        addAction(UIAlertAction(title: "Выбрать из галереи", style: .default) { _ in
            guard let picker = self.pickerController else {return}
            self.pickerController?.sourceType = .photoLibrary
            self.vc?.present(picker, animated: true) {
                self.pickerController?.vc = self.vc as? ProfileViewController
            }
        })

        addAction(UIAlertAction(title: "Отмена", style: .cancel))
    }
}
