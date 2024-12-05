import XCTest
@testable import RepoRadar

final class MockAPIService: APIServiceProtocol {
    var mockRepositories: [Repository] = []
    var shouldThrowError: Bool = false
    
    func fetchRepositories(page: Int) async throws -> [Repository] {
        if shouldThrowError {
            throw URLError(.badServerResponse)
        }
        return mockRepositories
    }
}

final class APIServiceTests: XCTestCase {
    private var apiService: APIServiceProtocol!
    
    override func setUp() {
        super.setUp()
        apiService = MockAPIService()
    }
    
    override func tearDown() {
        apiService = nil
        super.tearDown()
    }
    
    func testFetchRepositoriesSuccess() async throws {
        let mockService = apiService as! MockAPIService
        mockService.mockRepositories = [
            Repository(
                id: 1,
                name: "Repo1",
                description: "Description1",
                owner: Owner(login: "User1", avatarUrl: "http://example.com/avatar1")
            )
        ]
        
        let repositories = try await apiService.fetchRepositories(page: 1)
        XCTAssertEqual(repositories.count, 1)
        XCTAssertEqual(repositories.first?.name, "Repo1")
    }
    
    func testFetchRepositoriesFailure() async throws {
        let mockService = apiService as! MockAPIService
        mockService.shouldThrowError = true
        
        do {
            _ = try await apiService.fetchRepositories(page: 1)
            XCTFail("Expected error to be thrown, but no error was thrown.")
        } catch {
            XCTAssertEqual(error as? URLError, URLError(.badServerResponse))
        }
    }
}
