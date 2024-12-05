import SwiftUI

struct RepositoryListView: View {
    @StateObject private var viewModel: RepositoryListViewModel
    
    init(viewModel: RepositoryListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isError {
                    errorView
                } else {
                    listView
                }
            }
            .navigationTitle("Repositories")
            .task {
                await viewModel.loadInitialData()
            }
        }
    }
    
    private var errorView: some View {
        VStack {
            Text("Failed to load data")
                .foregroundColor(.red)
            Button("Retry") {
                Task {
                    await viewModel.loadInitialData()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    private var listView: some View {
        List {
            ForEach(viewModel.repositories, id: \.id) { repository in
                RepositoryRow(
                    repository: repository,
                    onUpdate: { updatedName in
                        Task {
                            var updatedRepository = repository
                            updatedRepository.name = updatedName
                            await viewModel.updateRepository(updatedRepository)
                        }
                    }
                )
                .onAppear {
                    if repository == viewModel.repositories.last {
                        Task {
                            try await viewModel.loadMoreData()
                        }
                    }
                }
            }
            .onDelete(perform: deleteRepositories)
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
    }
    
    private func deleteRepositories(at offsets: IndexSet) {
        Task {
            for index in offsets {
                let repository = viewModel.repositories[index]
                await viewModel.deleteRepository(repository)
            }
        }
    }
}
