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
        
// retain cycle может возникнуть в ситуации, когда мы не пропишем weak в списке захвата клоужера или в проперти делегата
// в такой ситуации, будет возникать лишняя ссылка на этот ThemeService, при чем на себя самого
// конкретно в моем приложении данный сервис применяется на всех контроллерах поэтому он не высвободится из памяти
// но например, если мы хотим красить только ConversationViewController, то при его закрытии ThemeService удалится из памяти, так как ConversationViewController ссылается слабо на ThemeService
        
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
