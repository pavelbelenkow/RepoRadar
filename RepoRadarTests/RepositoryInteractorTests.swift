import XCTest
@testable import RepoRadar

final class RepositoryInteractorTests: XCTestCase {
    var mockRepository: MockRepository!
    var interactor: RepositoryInteractor!

    override func setUp() {
        super.setUp()
        mockRepository = MockRepository()
        interactor = RepositoryInteractor(repository: mockRepository)
    }

    func testLoadRepositoriesSuccess() async throws {
        let sampleRepositories = [Repository(id: 1, name: "Repo1", description: "Description1", owner: Owner(login: "User1", avatarUrl: ""))]
        mockRepository.remoteRepositories = sampleRepositories

        let repositories = try await interactor.loadRepositories(page: 1)

        XCTAssertEqual(repositories, sampleRepositories)
        XCTAssertEqual(mockRepository.savedRepositories, sampleRepositories)
    }

    func testLoadRepositoriesFailure() async {
        mockRepository.shouldThrowError = true

        do {
            _ = try await interactor.loadRepositories(page: 1)
            XCTFail("Expected error but got none")
        } catch {
            XCTAssertEqual(error as? URLError, URLError(.badServerResponse))
        }
    }

    func testFetchLocalRepositoriesSuccess() async throws {
        let sampleRepositories = [Repository(id: 1, name: "Local", description: "Description1", owner: Owner(login: "User1", avatarUrl: ""))]
        mockRepository.localRepositories = sampleRepositories

        let repositories = try await interactor.fetchLocalRepositories()

        XCTAssertEqual(repositories, sampleRepositories)
    }

    func testDeleteRepository() async throws {
        let repositoryToDelete = Repository(id: 1, name: "ToDelete", description: "Description1", owner: Owner(login: "User1", avatarUrl: ""))
        mockRepository.deletedRepositories = []

        try await interactor.deleteRepository(repositoryToDelete)

        XCTAssertEqual(mockRepository.deletedRepositories, [repositoryToDelete])
    }

    func testUpdateRepository() async throws {
        let repositoryToUpdate = Repository(id: 1, name: "OldName", description: "Description1", owner: Owner(login: "User1", avatarUrl: ""))
        mockRepository.updatedRepositories = []

        try await interactor.updateRepository(repositoryToUpdate)

        XCTAssertEqual(mockRepository.updatedRepositories, [repositoryToUpdate])
    }
}
