import Foundation

protocol RepositoryListViewModelProtocol: ObservableObject {
    var repositories: [Repository] { get set }
    var isLoading: Bool { get set }
    var isError: Bool { get set }
    var errorMessage: String { get set }

    func loadInitialData() async
    func loadMoreData() async throws
    func deleteRepository(_ repository: Repository) async
    func updateRepository(_ repository: Repository) async
}

final class RepositoryListViewModel: RepositoryListViewModelProtocol {
    private let interactor: RepositoryUseCase
    private var currentPage = 1
    
    @Published var repositories: [Repository] = []
    @Published var isLoading: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    
    init(interactor: RepositoryUseCase) {
        self.interactor = interactor
    }
    
    @MainActor
    func loadInitialData() async {
        do {
            let localRepositories = try await interactor.fetchLocalRepositories()
            repositories = localRepositories
            
            currentPage = (repositories.count / 30) + 1
            
            try await loadMoreData()
        } catch {
            handle(error)
        }
    }
    
    @MainActor
    func loadMoreData() async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let newRepositories = try await interactor.loadRepositories(page: currentPage)
            
            let localIDs = Set(repositories.map { $0.id })
            let uniqueRepositories = newRepositories.filter { !localIDs.contains($0.id) }
            
            if !uniqueRepositories.isEmpty {
                repositories.append(contentsOf: uniqueRepositories)
            }
            
            currentPage += 1
        } catch {
            handle(error)
        }
    }
    
    @MainActor
    func deleteRepository(_ repository: Repository) async {
        do {
            try await interactor.deleteRepository(repository)
            repositories.removeAll { $0.id == repository.id }
        } catch {
            handle(error)
        }
    }
    
    @MainActor
    func updateRepository(_ repository: Repository) async {
        do {
            try await interactor.updateRepository(repository)
            if let index = repositories.firstIndex(where: { $0.id == repository.id }) {
                repositories[index] = repository
            }
        } catch {
            handle(error)
        }
    }
    
    private func handle(_ error: Error) {
        isError = true
        errorMessage = error.localizedDescription
        print("Error: \(error)")
    }
}
