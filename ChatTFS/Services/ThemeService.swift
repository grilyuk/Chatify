//
//  ThemeService.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 13.03.2023.
//

import UIKit

enum Theme {
    case day
    case night
}

protocol ThemeServiceProtocol: AnyObject {
    var choosenTheme: Theme? { get }
}

class ThemeService {
    var choosenTheme: Theme?
    
}
