import SwiftUI
import SwiftData

struct GenresView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Genre.name) private var genres: [Genre]
    @State private var newGenreName = ""
    @State private var genreToDelete: Genre?
    @State private var showingDeleteConfirmation = false

    private var cleanName: String { newGenreName.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isDuplicate: Bool {
        genres.contains { $0.name.localizedCaseInsensitiveCompare(cleanName) == .orderedSame }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Новый жанр") {
                    TextField("Название жанра", text: $newGenreName)
                    Button("Добавить") {
                        modelContext.insert(Genre(name: cleanName))
                        newGenreName = ""
                    }
                    .disabled(cleanName.isEmpty || isDuplicate)
                    if isDuplicate {
                        Text("Такой жанр уже есть").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Section {
                    ForEach(genres) { genre in
                        HStack {
                            Text(genre.name)
                            Spacer()
                            Text("\(genre.movies.count)").foregroundStyle(.secondary)
                        }
                        .swipeActions {
                            Button("Удалить", role: .destructive) {
                                genreToDelete = genre
                                showingDeleteConfirmation = true
                            }
                        }
                    }
                } header: {
                    Text("Жанры: \(genres.count)")
                }
            }
            .navigationTitle("Жанры")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Готово") { dismiss() }
                }
            }
            .confirmationDialog("Удалить жанр «\(genreToDelete?.name ?? "")»? Фильмы останутся.",
                                isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Удалить жанр", role: .destructive) {
                    if let genre = genreToDelete { modelContext.delete(genre) }
                    genreToDelete = nil
                }
                Button("Отмена", role: .cancel) { genreToDelete = nil }
            }
        }
    }
}
