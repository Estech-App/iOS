
import Foundation

enum MentoringStatus: String {
    case approved = "APPROVED"
    case denied = "DENIED"
    case pending = "PENDING"
    case modified = "MODIFIED"
}

struct Mentoring {
    let id: Int
    let roomId: Int
    let date: Date
    let status: MentoringStatus
    let student: Person
    let teacher: Person
}


struct Person {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    
    
    var fullName: String {
        firstName + " " + lastName
    }
}
