

import Foundation
import BDRCoreNetwork
enum SessionRole {
    case teacher
    case student
}

class SessionManager {
    static let shared = SessionManager()
    
    var role: SessionRole?
    var user: User?
    
    func openSession(_ response: LoginResponse) {
        if response.roles.contains(where: { $0.authority == "ROLE_TEACHER" }) {
            role = .teacher
        } else if response.roles.contains(where: { $0.authority == "ROLE_STUDENT" }) {
            role = .student
        }
        
        TokenManager.shared.saveAccessToken(token: response.token)
    }
    
    func saveUserInfo(_ response: UserInfoResponse) {
        user = User(
            firstName: response.name ?? "",
            lastName: response.lastname ?? "",
            email: response.email ?? "",
            id: response.id,
            role: role ?? .student
        )
    }
}
