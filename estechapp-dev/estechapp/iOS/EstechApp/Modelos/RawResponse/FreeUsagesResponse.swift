

import Foundation


struct FreeUsagesResponse: Codable {
    let id: Int
    let start: String?
    let status: String?
    let room: RoomResponse?
    let user: StudentResponse?
}
struct RoomResponse: Codable {
    let id: Int
    let name: String?
    let description: String?
    let mentoringRoom: Bool?
    let studyRoom: Bool?
    let timeTables: [FreeUsagesTimetables]?
}
struct FreeUsagesTimetables: Codable {
    let id: Int
    let status: String?
    let start: String?
    let roomId: Int?
    
}
