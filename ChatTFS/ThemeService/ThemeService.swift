import UIKit

protocol ThemeServiceProtocol: AnyObject {
    var currentTheme: Theme { get set }
}

class ThemeService: ThemeServiceProtocol {
    
    //MARK: - Private
    private let standart = UserDefaults.standard
    private let key = "Theme"
    
    //MARK: - Public
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
}
