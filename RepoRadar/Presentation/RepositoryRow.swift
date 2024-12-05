import SwiftUI

struct RepositoryRow: View {
    @State private var isEditing = false
    @State private var updatedName = ""
    
    let repository: Repository
    let onUpdate: (String) -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            
            AsyncImage(url: URL(string: repository.owner.avatarUrl)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } placeholder: {
                ProgressView()
                    .frame(width: 50, height: 50)
            }
            
            LazyVStack(alignment: .leading) {
                if isEditing {
                    TextField("Repository Name", text: $updatedName, onCommit: {
                        onUpdate(updatedName)
                        isEditing = false
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    Text(repository.name)
                        .font(.headline)
                        .onTapGesture {
                            updatedName = repository.name
                            isEditing = true
                        }
                }
                
                Text(repository.description ?? "No description")
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 8)
    }
}
