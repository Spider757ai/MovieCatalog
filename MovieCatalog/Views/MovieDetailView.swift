import SwiftUI
import SwiftData

struct MovieDetailView: View {
    @Bindable var movie: Movie
    @Query(sort: \Genre.name) private var genres: [Genre]
    @State private var showingGenres = false

    var body: some View {
        Form {
            Section("Фильм") {
                TextField("Название", text: $movie.title)
                    .onChange(of: movie.title) { oldValue, newValue in
                        if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            movie.title = oldValue
                        }
                    }
                Picker("Жанр", selection: $movie.genre) {
                    if movie.genre == nil {
                        Text("Без жанра").tag(nil as Genre?)
                    }
                    ForEach(genres) { genre in
                        Text(genre.name).tag(genre as Genre?)
                    }
                }
                Button("Управление жанрами") { showingGenres = true }
                Stepper("Год: \(movie.year.formatted(.number.grouping(.never)))", value: $movie.year, in: 1888...2100)
            }
            Section("Статус") {
                Toggle("Просмотрено", isOn: $movie.isWatched)
                Toggle("Избранное", isOn: $movie.isFavorite)
                Stepper(movie.rating == 0 ? "Без оценки" : "Оценка: \(movie.rating) / 5",
                        value: $movie.rating, in: 0...5)
            }
        }
        .navigationTitle("Редактирование")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingGenres) { GenresView() }
    }
}
