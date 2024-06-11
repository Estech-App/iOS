
import Foundation
// MARK: - Temperature
struct GroupsResponse: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let evening: Bool?
    let year: String?
    let courseID: Int?
    let roomID: Int?
    let users: [UserResponse]?
    let timeTables: [TimeTable]?

    enum CodingKeys: String, CodingKey {
        case id, name, description, evening, year
        case courseID
        case roomID
        case users, timeTables
    }
}

// MARK: - TimeTable
struct TimeTable: Codable {
    let id, schoolGroupID, moduleID: Int?
    let start, end, weekday: String?

    enum CodingKeys: String, CodingKey {
        case id
        case schoolGroupID
        case moduleID
        case start, end, weekday
    }
}

// MARK: - User
struct UserResponse: Codable {
    let id: Int?
    let email, name, lastname, role: String?
}
