import SwiftUI
import SwiftData

struct MovieListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var movies: [Movie]
    @Binding var selection: Set<PersistentIdentifier>
    let isSelecting: Bool
    let catalogIsEmpty: Bool

    init(searchText: String, filter: WatchFilter, sort: MovieSort,
         favoritesOnly: Bool, isSelecting: Bool, catalogIsEmpty: Bool,
         selection: Binding<Set<PersistentIdentifier>>) {
        _movies = Query(filter: filter.predicate(searchText: searchText, favoritesOnly: favoritesOnly),
                        sort: sort.descriptors)
        _selection = selection
        self.isSelecting = isSelecting
        self.catalogIsEmpty = catalogIsEmpty
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(movies) { movie in
                if isSelecting {
                    MovieRow(movie: movie, isSelecting: true)
                        .tag(movie.persistentModelID)
                } else {
                    NavigationLink {
                        MovieDetailView(movie: movie)
                    } label: {
                        MovieRow(movie: movie)
                    }
                    .tag(movie.persistentModelID)
                }
            }
            .onDelete(perform: deleteMovies)
        }
        .overlay {
            if movies.isEmpty {
                ContentUnavailableView(
                    catalogIsEmpty ? "Фильмов пока нет" : "Ничего не найдено",
                    systemImage: catalogIsEmpty ? "film" : "magnifyingglass",
                    description: Text(catalogIsEmpty ? "Добавьте первый фильм кнопкой +" : "Измените поиск или фильтры")
                )
            }
        }
    }

    private func deleteMovies(at offsets: IndexSet) {
        let deletedMovies = offsets.map { movies[$0] }
        for movie in deletedMovies {
            selection.remove(movie.persistentModelID)
            modelContext.delete(movie)
        }
    }
}
