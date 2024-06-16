
import Foundation


struct FreeUsages {
    let id: Int
    let roomId: Int
    let start: Date
    let status: MentoringStatus
    let name: String
    let description: String
    let mentoringRoom: Bool
    let studyRoom: Bool
    let timeTables: [Timetables]
    let user: Person
}

struct Timetables {
    let id: Int
    let status: String
    let start: String
    let dayOfWeek: String
    let reccurence: String
    let roomId: Int
    
}

