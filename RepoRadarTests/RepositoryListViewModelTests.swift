import XCTest
@testable import RepoRadar

final class MockRepositoryListViewModel: RepositoryListViewModelProtocol {
    var repositories: [Repository] = []
    var isLoading: Bool = false
    var isError: Bool = false
    var errorMessage: String = ""

    var shouldThrowError: Bool = false

    func loadInitialData() async {
        if shouldThrowError {
            isError = true
            errorMessage = "Mock error"
        } else {
            repositories = [
                Repository(
                    id: 1,
                    name: "Test Repository",
                    description: "Test Description",
                    owner: Owner(login: "Test User", avatarUrl: "")
                )
            ]
        }
    }

    func loadMoreData() async throws {
        if shouldThrowError {
            throw URLError(.cannotLoadFromNetwork)
        }
        repositories.append(contentsOf: [
            Repository(
                id: 2,
                name: "More Repository 2",
                description: "Test Description 2",
                owner: Owner(login: "Test User 2", avatarUrl: "")
            ),
            Repository(
                id: 3,
                name: "More Repository 3",
                description: "Test Description 3",
                owner: Owner(login: "Test User 3", avatarUrl: "")
            )
        ])
    }

    func deleteRepository(_ repository: Repository) async {
        if let index = repositories.firstIndex(where: { $0.id == repository.id }) {
            repositories.remove(at: index)
        }
    }

    func updateRepository(_ repository: Repository) async {
        if let index = repositories.firstIndex(where: { $0.id == repository.id }) {
            repositories[index] = repository
        }
    }
}

final class RepositoryListViewModelTests: XCTestCase {
    var viewModel: MockRepositoryListViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MockRepositoryListViewModel()
    }

    func testLoadInitialDataSuccess() async throws {
        viewModel.shouldThrowError = false
        
        await viewModel.loadInitialData()

        XCTAssertEqual(viewModel.repositories.count, 1)
        XCTAssertFalse(viewModel.isError)
    }

    func testLoadInitialDataFailure() async throws {
        viewModel.shouldThrowError = true

        await viewModel.loadInitialData()

        XCTAssertTrue(viewModel.isError)
        XCTAssertEqual(viewModel.errorMessage, "Mock error")
    }

    func testLoadMoreData() async throws {
        viewModel.shouldThrowError = false

        try await viewModel.loadMoreData()

        XCTAssertEqual(viewModel.repositories.count, 2)
    }

    func testDeleteRepositorySuccess() async {
        let repositoryToDelete = Repository(
            id: 1,
            name: "Test Repository",
            description: "Test Description",
            owner: Owner(login: "Test User", avatarUrl: "")
        )
        viewModel.repositories = [repositoryToDelete]

        await viewModel.deleteRepository(repositoryToDelete)

        XCTAssertEqual(viewModel.repositories.count, 0)
    }

    func testUpdateRepositorySuccess() async {
        let repositoryToUpdate = Repository(
            id: 1,
            name: "Old Repository",
            description: "Description",
            owner: Owner(login: "Test User", avatarUrl: "")
        )
        viewModel.repositories = [repositoryToUpdate]
        
        let updatedRepository = Repository(
            id: 1,
            name: "Updated Repository",
            description: "Description",
            owner: Owner(login: "Test User", avatarUrl: "")
        )

        await viewModel.updateRepository(updatedRepository)

        XCTAssertEqual(viewModel.repositories.first?.name, "Updated Repository")
    }
}