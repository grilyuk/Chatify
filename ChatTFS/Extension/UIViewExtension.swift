import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    func keyboard(showKeyboard: Selector, hideKeyboard: Selector) {
        NotificationCenter.default.addObserver(self,
                                               selector: showKeyboard,
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: hideKeyboard,
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    func showKeyboard(_ notification: Notification, view: UIViewController) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {return}
        
        let keyboardHeight = keyboardFrame.height
        let viewYMax = self.frame.maxY
        let safeAreaYMax = self.safeAreaLayoutGuide.layoutFrame.maxY
        let height = viewYMax - safeAreaYMax
        let offset = keyboardHeight - height
        view.additionalSafeAreaInsets.bottom = offset
        self.layoutIfNeeded()
    }
    
    func hideKeyboard(_ notification: Notification, view: UIViewController) {
        view.additionalSafeAreaInsets.bottom = 0
    }
}
