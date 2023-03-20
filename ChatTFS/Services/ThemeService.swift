import UIKit

protocol ThemePickerDelegate: AnyObject {
    func changeTheme(theme: Theme)
}

protocol ThemeServiceProtocol: AnyObject {
    var themeHandler: ((Theme) -> Void)? { get set }
    var currentTheme: Theme { get set }
    func updateTheme()
}

class ThemeService: ThemeServiceProtocol {
    
    //MARK: - Private
    private let standart = UserDefaults.standard
    private let key = "Theme"
    
    //MARK: - Public
    weak var themeDelegate: ThemePickerDelegate?
    var themeHandler: ((Theme) -> Void)?
    var currentTheme: Theme {
        get {
            guard let value = standart.value(forKey: key) as? String,
                  let theme = Theme(rawValue: value) else { return .light }
            return theme
        }
        set {
            standart.set(newValue.rawValue, forKey: key)
        }
    }
    
    //MARK: - Methods
    func updateTheme() {
        themeDelegate = self
        themeHandler = { [weak self] theme in
            self?.currentTheme = theme
        }
    }
}

//MARK: - ThemeService + ThemePickerDelegate
extension ThemeService: ThemePickerDelegate {
    func changeTheme(theme: Theme) {
        currentTheme = theme
    }
}
