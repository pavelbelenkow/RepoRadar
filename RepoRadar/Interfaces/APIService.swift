import Foundation

protocol APIServiceProtocol {
    func fetchRepositories(page: Int) async throws -> [Repository]
}

final class APIService: APIServiceProtocol {
    private let baseURL = "https://api.github.com/search/repositories?q=swift&sort=stars&order=asc"
    
    func fetchRepositories(page: Int) async throws -> [Repository] {
        let urlString = "\(baseURL)&page=\(page)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedResponse = try JSONDecoder().decode(RepositoryResponse.self, from: data)
        return decodedResponse.items
    }
}
