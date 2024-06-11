

import Foundation

struct LoginResponse: Codable {
    let roles: [Role]
    let message: String
    let token: String
    let username: String
}

// Modelo para representar el rol de un usuario
struct Role: Codable {
    let authority: String
}

