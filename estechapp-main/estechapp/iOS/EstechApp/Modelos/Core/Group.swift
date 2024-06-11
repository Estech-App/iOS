
import Foundation
import UIKit

struct Group {
    
    let type: String
    let numberGroup: Int
    let numberStudents: Int
    
    var image: UIImage {
        UIImage(named: name) ?? .DAM
    }
    
    var name: String {
        "\(type) \(numberGroup)"
    }
}
