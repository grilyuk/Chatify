import Foundation

extension String {
    func isLink() -> Bool {
        self.hasPrefix("http")
    }
}
