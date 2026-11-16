import SwiftUI
import SwiftData

struct AddMovieView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Genre.name) private var genres: [Genre]
    @State private var title = ""
    @State private var year = Calendar.current.component(.year, from: .now)
    @State private var selectedGenre: Genre?
    @State private var newGenreName = ""

    private var cleanTitle: String { title.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var cleanGenre: String { newGenreName.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        NavigationStack {
            Form {
                Section("Фильм") {
                    TextField("Название", text: $title)
                    Stepper("Год: \(year.formatted(.number.grouping(.never)))", value: $year, in: 1888...2100)
                }
                Section("Жанр") {
                    Picker("Жанр", selection: $selectedGenre) {
                        Text("Новый жанр").tag(nil as Genre?)
                        ForEach(genres) { genre in
                            Text(genre.name).tag(genre as Genre?)
                        }
                    }
                    if selectedGenre == nil {
                        TextField("Название жанра", text: $newGenreName)
                    }
                }
            }
            .navigationTitle("Новый фильм")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") { saveMovie() }
                        .disabled(cleanTitle.isEmpty || (selectedGenre == nil && cleanGenre.isEmpty))
                }
            }
        }
    }

    private func saveMovie() {
        guard !cleanTitle.isEmpty, selectedGenre != nil || !cleanGenre.isEmpty else { return }
        var genre = selectedGenre
        if genre == nil {
            genre = genres.first { $0.name.localizedCaseInsensitiveCompare(cleanGenre) == .orderedSame }
            if genre == nil {
                let newGenre = Genre(name: cleanGenre)
                modelContext.insert(newGenre)
                genre = newGenre
            }
        }
        modelContext.insert(Movie(title: cleanTitle, year: year, genre: genre))
        dismiss()
    }
}
