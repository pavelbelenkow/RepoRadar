import SwiftUI
import SwiftData

@main
struct RepoRadarApp: App {
    private var viewModel: RepositoryListViewModel
    
    init() {
        do {
            let container = try ModelContainer(for: RepositoryEntity.self)
            let apiService = APIService()
            let repositoryRepository = RepositoryRepository(apiService: apiService, context: ModelContext(container))
            let repositoryInteractor = RepositoryInteractor(repository: repositoryRepository)
            viewModel = RepositoryListViewModel(interactor: repositoryInteractor)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            RepositoryListView(viewModel: viewModel)
        }
    }
}

