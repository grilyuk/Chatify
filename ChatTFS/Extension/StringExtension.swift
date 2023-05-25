import Foundation

extension String {
    func isLink() -> Bool {
        self.hasPrefix("http")
    }
    
    func emptyText() -> Bool {
        trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }
}
