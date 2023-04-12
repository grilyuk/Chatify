import Foundation

class Logger {
    
    var description = ""
    
    enum Result: Equatable {
        case success
        case failure
    }
    
    func displayLog(result: Result, isMainThread: Bool, activity: String) {
        switch result {
        case .success:
            description = "Is main thread: - \(isMainThread), \(activity)"
        case .failure:
            description = "Failure during \(activity)"
        }
    #if DEBUG
        print(description)
    #endif
    }
}
