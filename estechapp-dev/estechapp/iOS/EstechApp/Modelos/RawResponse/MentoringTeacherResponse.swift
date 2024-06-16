
import Foundation

struct MentoringTeacherResponse: Codable {
    let id: Int
    let roomId: Int?
    let start: String?
    let status: String?
    let student: StudentResponse?
    let teacher: TeacherResponse?
}


struct StudentResponse: Codable {
    let email: String
    let id: Int
    let lastname: String?
    let name: String?
}


struct TeacherResponse: Codable {
    let email: String
    let id: Int
    let lastname: String?
    let name: String?
}
