import SwiftData

@Model
final class RepositoryEntity {
    @Attribute(.unique) var id: Int
    var name: String
    var descriptionText: String?
    var ownerName: String
    var ownerAvatarURL: String
    
    init(id: Int, name: String, descriptionText: String?, ownerName: String, ownerAvatarURL: String) {
        self.id = id
        self.name = name
        self.descriptionText = descriptionText
        self.ownerName = ownerName
        self.ownerAvatarURL = ownerAvatarURL
    }
    
    convenience init(from repository: Repository) {
        self.init(
            id: repository.id,
            name: repository.name,
            descriptionText: repository.description,
            ownerName: repository.owner.login,
            ownerAvatarURL: repository.owner.avatarUrl
        )
    }
    
    func toRepository() -> Repository {
        Repository(
            id: id,
            name: name,
            description: descriptionText,
            owner: Owner(login: ownerName, avatarUrl: ownerAvatarURL)
        )
    }
}
