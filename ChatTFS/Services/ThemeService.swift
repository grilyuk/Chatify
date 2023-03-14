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
    
    weak var themeDelegate: ThemePickerDelegate?
    private let standart = UserDefaults.standard
    private let key = "Theme"
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
    
    func updateTheme() {
        themeDelegate = self
        themeHandler = { [weak self] theme in
            self?.currentTheme = theme
        }
    }
}

extension ThemeService: ThemePickerDelegate {
    func changeTheme(theme: Theme) {
        currentTheme = theme
    }
}
