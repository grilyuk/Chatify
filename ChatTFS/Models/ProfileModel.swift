import UIKit
import Combine

struct ProfileModel: Codable {
    let fullName: String?
    let statusText: String?
    let profileImageData: Data?
    var id = UUID().uuidString
}
