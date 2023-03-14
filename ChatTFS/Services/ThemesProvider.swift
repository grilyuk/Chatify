//TEST
//FIRST TRY

import UIKit

protocol ThemeProtocol: Any {
    var backgroundColor: UIColor { get set }
}

protocol ViewSubscriber: UIViewController {
    func changeTheme(theme: ThemeProtocol)
}

struct AnotherTheme: ThemeProtocol {
    var backgroundColor: UIColor = UIColor(red: 0.8, green: 0.3, blue: 0.7, alpha: 1)
}

class ThemeProvider {
    
    private lazy var theme: ThemeProtocol = AnotherTheme()
    private lazy var subscribers = [ViewSubscriber]()
    
    func add(subscriber: ViewSubscriber) {
        subscribers.append(subscriber)
    }

    private func notifySubscribers() {
        subscribers.forEach({$0.changeTheme(theme: theme)})
    }
}
