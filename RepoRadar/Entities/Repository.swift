import Foundation

struct Repository: Identifiable, Decodable, Equatable {
    let id: Int
    var name: String
    let description: String?
    let owner: Owner
    
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        lhs.id == rhs.id
    }
}


