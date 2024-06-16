
import Foundation

struct Room {
    let id: Int
    let roomId: Int
    
    var name: String {
        "Aula #\(roomId)"
    }
}
