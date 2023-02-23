//
//  Logger.swift
//  ChatTFS
//
//  Created by Григорий Данилюк on 20.02.2023.
//

import Foundation

class Logger {
    
    var shouldLog: Bool
    var logType: LogType
    var description = ""
    
    init(shouldLog: Bool, logType: LogType) {
        self.shouldLog = shouldLog
        self.logType = logType
    }
    
    enum LogType {
        case app
        case viewController
        case frame
    }
    
    func handleLog(function: String = #function, actualState: String?, previousState: String?) {
        if shouldLog == true {
            switch logType {
            case .app:
                description = "Application moved from \(previousState ?? "") to \(actualState ?? ""): \(function)"
            case .viewController:
                description = "Called method: \(function)"
            case .frame:
                description = ""
            }
            
            #if DEBUG
            print(description)
            #endif
        }
    }
    
    func handleFrame(frame: String?) {
        if shouldLog == true {
            description = "Frame is: \(frame ?? "")"
        }
        #if DEBUG
        print(description)
        #endif
    }
}
