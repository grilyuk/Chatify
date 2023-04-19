import UIKit

enum Theme: String {
    case light
    case dark
    
    var backgroundColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 0.8874980807, green: 0.9828771949, blue: 1, alpha: 1)
        case .dark:
            return #colorLiteral(red: 0.1921568662, green: 0.007843137719, blue: 0.2137611315, alpha: 1)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        case .dark:
            return #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        }
    }
    
    var incomingTextColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .dark:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var outgoingTextColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .dark:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    var themeBubble: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .dark:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
    
    var incomingBubbleColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 0.7952535152, green: 0.7952535152, blue: 0.7952535152, alpha: 1)
        case .dark:
            return #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
        }
    }
    
    var outgoingBubbleColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        case .dark:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}
