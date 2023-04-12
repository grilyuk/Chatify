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
            description = "success \(activity) -- Is main thread: - \(isMainThread)"
        case .failure:
            description = "failure \(activity) -- Is main thread: - \(isMainThread)"
        }
    #if DEBUG
        print(description)
    #endif
    }
}
