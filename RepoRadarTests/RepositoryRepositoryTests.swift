import XCTest
@testable import RepoRadar

final class MockRepository: RepositoryDataSource {
    var remoteRepositories: [Repository] = []
    var localRepositories: [Repository] = []
    var savedRepositories: [Repository] = []
    var deletedRepositories: [Repository] = []
    var updatedRepositories: [Repository] = []
    var shouldThrowError: Bool = false

    func fetchRepositories(page: Int) async throws -> [Repository] {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return remoteRepositories
    }

    func saveRepositories(_ repositories: [Repository]) async throws {
        if shouldThrowError {
            throw URLError(.cannotCreateFile)
        }
        savedRepositories.append(contentsOf: repositories)
    }

    func fetchLocalRepositories() async throws -> [Repository] {
        if shouldThrowError {
            throw URLError(.cannotLoadFromNetwork)
        }
        return localRepositories
    }

    func deleteRepository(_ repository: Repository) async throws {
        if shouldThrowError {
            throw URLError(.cannotRemoveFile)
        }
        deletedRepositories.append(repository)
    }

    func updateRepository(_ repository: Repository) async throws {
        if shouldThrowError {
            throw URLError(.cannotWriteToFile)
        }
        updatedRepositories.append(repository)
    }
}

final class RepositoryRepositoryTests: XCTestCase {
    private var repository: RepositoryDataSource!
    private var mockRepository: MockRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockRepository()
        repository = mockRepository
    }

    override func tearDown() {
        repository = nil
        mockRepository = nil
        super.tearDown()
    }

    func testFetchRepositoriesSuccess() async throws {
        mockRepository.remoteRepositories = [
            Repository(id: 1, name: "Repo1", description: "Description1", owner: Owner(login: "User1", avatarUrl: ""))
        ]

        let repositories = try await repository.fetchRepositories(page: 1)
        XCTAssertEqual(repositories.count, 1)
        XCTAssertEqual(repositories.first?.name, "Repo1")
    }

    func testFetchRepositoriesFailure() async throws {
        mockRepository.shouldThrowError = true

        do {
            _ = try await repository.fetchRepositories(page: 1)
            XCTFail("Expected error but did not throw")
        } catch {
            XCTAssertEqual(error as? URLError, URLError(.badServerResponse))
        }
    }

    func testSaveRepositories() async throws {
        let repositories = [
            Repository(id: 1, name: "Repo1", description: "Description1", owner: Owner(login: "User1", avatarUrl: ""))
        ]

        try await repository.saveRepositories(repositories)

        XCTAssertEqual(mockRepository.savedRepositories.count, 1)
        XCTAssertEqual(mockRepository.savedRepositories.first?.name, "Repo1")
    }

    func testFetchLocalRepositories() async throws {
        mockRepository.localRepositories = [
            Repository(id: 2, name: "LocalRepo1", description: "Description2", owner: Owner(login: "User2", avatarUrl: ""))
        ]

        let repositories = try await repository.fetchLocalRepositories()
        XCTAssertEqual(repositories.count, 1)
        XCTAssertEqual(repositories.first?.name, "LocalRepo1")
    }

    func testDeleteRepository() async throws {
        let repositoryToDelete = Repository(id: 3, name: "RepoToDelete", description: "Description3", owner: Owner(login: "User3", avatarUrl: ""))

        try await repository.deleteRepository(repositoryToDelete)

        XCTAssertEqual(mockRepository.deletedRepositories.count, 1)
        XCTAssertEqual(mockRepository.deletedRepositories.first?.name, "RepoToDelete")
    }

    func testUpdateRepository() async throws {
        let repositoryToUpdate = Repository(id: 4, name: "RepoToUpdate", description: "Description4", owner: Owner(login: "User4", avatarUrl: ""))

        try await repository.updateRepository(repositoryToUpdate)

        XCTAssertEqual(mockRepository.updatedRepositories.count, 1)
        XCTAssertEqual(mockRepository.updatedRepositories.first?.name, "RepoToUpdate")
    }
}