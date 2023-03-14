import UIKit

enum Theme: String {
    case light
    case dark
    
    var backgroundColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 0.8761214018, green: 0.7995334268, blue: 0.8573057055, alpha: 1)
        case .dark:
            return #colorLiteral(red: 0.08247876912, green: 0.06155637652, blue: 0.2980254889, alpha: 1)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .light:
            return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .dark:
            return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
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
}
