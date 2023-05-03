import Foundation

extension String {
    func isLink() -> Bool {
        self.hasPrefix("http")
    }
    
    func removeWhitespacesPrefix() -> Bool {
        trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
}
