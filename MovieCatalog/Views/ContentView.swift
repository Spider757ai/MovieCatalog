import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var movies: [Movie]
    @State private var showingAddMovie = false
    @State private var showingGenres = false
    @State private var searchText = ""
    @State private var filter: WatchFilter = .all
    @State private var sort: MovieSort = .newest
    @State private var favoritesOnly = false
    @State private var editMode: EditMode = .inactive
    @State private var selection: Set<PersistentIdentifier> = []
    @State private var showingDeleteConfirmation = false

    private var averageRating: Double {
        let ratedMovies = movies.filter { $0.rating > 0 }
        guard !ratedMovies.isEmpty else { return 0 }
        return Double(ratedMovies.reduce(0) { $0 + $1.rating }) / Double(ratedMovies.count)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Всего: \(movies.count)")
                        Spacer()
                        Text("Просмотрено: \(movies.filter { $0.isWatched }.count)")
                    }
                    Text("Средняя оценка: \(averageRating, specifier: "%.1f") / 5")
                    Picker("Статус", selection: $filter) {
                        ForEach(WatchFilter.allCases) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    HStack {
                        Toggle("Избранное", isOn: $favoritesOnly)
                            .toggleStyle(.button)
                        Spacer()
                        Picker("Сортировка", selection: $sort) {
                            ForEach(MovieSort.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .font(.subheadline)
                .padding()

                MovieListView(searchText: searchText, filter: filter, sort: sort,
                              favoritesOnly: favoritesOnly, isSelecting: editMode.isEditing,
                              catalogIsEmpty: movies.isEmpty, selection: $selection)
            }
            .navigationTitle("Фильмы")
            .searchable(text: $searchText, prompt: "Название или жанр")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Жанры") { showingGenres = true }
                        .disabled(editMode.isEditing)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button(editMode.isEditing ? "Готово" : "Выбрать") {
                        selection.removeAll()
                        editMode = editMode.isEditing ? .inactive : .active
                    }
                    Button("Добавить фильм", systemImage: "plus") { showingAddMovie = true }
                        .disabled(editMode.isEditing)
                }
                if editMode.isEditing {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Text("Выбрано: \(selection.count)")
                        Spacer()
                        Button("Просмотрено", systemImage: "checkmark.circle") { markSelectedAsWatched() }
                            .disabled(selection.isEmpty)
                        Button("Удалить", systemImage: "trash", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                        .disabled(selection.isEmpty)
                    }
                }
            }
            .environment(\.editMode, $editMode)
            .sheet(isPresented: $showingAddMovie) { AddMovieView() }
            .sheet(isPresented: $showingGenres) { GenresView() }
            .confirmationDialog("Удалить выбранные фильмы: \(selection.count)?",
                                isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
                Button("Удалить", role: .destructive) { deleteSelectedMovies() }
                Button("Отмена", role: .cancel) { }
            }
            .onChange(of: searchText) { selection.removeAll() }
            .onChange(of: filter) { selection.removeAll() }
            .onChange(of: favoritesOnly) { selection.removeAll() }
        }
    }

    private func markSelectedAsWatched() {
        for movie in movies where selection.contains(movie.persistentModelID) {
            movie.isWatched = true
        }
        selection.removeAll()
    }

    private func deleteSelectedMovies() {
        for movie in movies where selection.contains(movie.persistentModelID) {
            modelContext.delete(movie)
        }
        selection.removeAll()
    }
}
