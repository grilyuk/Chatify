//
//  Logger.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 20.02.2023.
//

import Foundation

class Logger {

    var shouldLog: Bool
    var description = ""

    init(shouldLog: Bool) {
        self.shouldLog = shouldLog
    }
    
    enum LogType {
        case app
        case viewController
    }

    func handleLog(function: String = #function, actualState: String?, previousState: String?) {
        if shouldLog == true {
            var logType: LogType

            if previousState == nil && actualState == nil {
                logType = .viewController
            } else {
                logType = .app
            }

            switch logType {
            case .app:
                description = "Application moved from \(previousState ?? "") to \(actualState ?? ""): \(function)"
            case .viewController:
                description = "Called method: \(function)"
            }

            #if DEBUG
            print(description)
            #endif
        }
    }
}
