import Foundation

protocol RepositoryUseCase {
    func loadRepositories(page: Int) async throws -> [Repository]
    func fetchLocalRepositories() async throws -> [Repository]
    func deleteRepository(_ repository: Repository) async throws
    func updateRepository(_ repository: Repository) async throws
}

final class RepositoryInteractor: RepositoryUseCase {
    private let repository: RepositoryDataSource
    
    init(repository: RepositoryDataSource) {
        self.repository = repository
    }
    
    func loadRepositories(page: Int) async throws -> [Repository] {
        let repositories = try await repository.fetchRepositories(page: page)
        try await repository.saveRepositories(repositories)
        return repositories
    }
    
    func fetchLocalRepositories() async throws -> [Repository] {
        try await repository.fetchLocalRepositories()
    }
    
    func deleteRepository(_ repository: Repository) async throws {
        try await self.repository.deleteRepository(repository)
    }
    
    func updateRepository(_ repository: Repository) async throws {
        try await self.repository.updateRepository(repository)
    }
}