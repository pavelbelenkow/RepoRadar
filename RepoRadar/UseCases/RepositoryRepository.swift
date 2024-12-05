import Foundation
import SwiftData

protocol RepositoryDataSource {
    func fetchRepositories(page: Int) async throws -> [Repository]
    func saveRepositories(_ repositories: [Repository]) async throws
    func fetchLocalRepositories() async throws -> [Repository]
    func deleteRepository(_ repository: Repository) async throws
    func updateRepository(_ repository: Repository) async throws
}

final class RepositoryRepository: RepositoryDataSource {
    private let apiService: APIServiceProtocol
    private let context: ModelContext
    
    init(apiService: APIService, context: ModelContext) {
        self.apiService = apiService
        self.context = context
    }
    
    func fetchRepositories(page: Int) async throws -> [Repository] {
        try await apiService.fetchRepositories(page: page)
    }
    
    func saveRepositories(_ repositories: [Repository]) async throws {
        
        for repository in repositories {
            let repositoryId = repository.id
            let fetchDescriptor = FetchDescriptor<RepositoryEntity>(
                predicate: #Predicate { entity in
                    entity.id == repositoryId
                }
            )
            
            let existingEntities = try context.fetch(fetchDescriptor)
            
            if existingEntities.isEmpty {
                context.insert(RepositoryEntity(from: repository))
            }
        }
        try context.save()
    }
    
    func fetchLocalRepositories() async throws -> [Repository] {
        let entities = try context.fetch(FetchDescriptor<RepositoryEntity>())
        return entities.map { $0.toRepository() }
    }
    
    func deleteRepository(_ repository: Repository) async throws {
        let repositoryId = repository.id
        let fetchDescriptor = FetchDescriptor<RepositoryEntity>(
            predicate: #Predicate { entity in
                entity.id == repositoryId
            }
        )
        
        let entities = try context.fetch(fetchDescriptor)
        for entity in entities {
            context.delete(entity)
        }
        try context.save()
    }
    
    func updateRepository(_ repository: Repository) async throws {
        let repositoryId = repository.id
        let fetchDescriptor = FetchDescriptor<RepositoryEntity>(
            predicate: #Predicate<RepositoryEntity> { entity in
                entity.id == repositoryId
            }
        )
        
        let entities = try context.fetch(fetchDescriptor)
        for entity in entities {
            entity.name = repository.name
            entity.descriptionText = repository.description
            entity.ownerName = repository.owner.login
            entity.ownerAvatarURL = repository.owner.avatarUrl
        }
        try context.save()
    }
}
