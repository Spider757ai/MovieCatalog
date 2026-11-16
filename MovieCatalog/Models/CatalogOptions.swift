import Foundation
import SwiftData

enum WatchFilter: String, CaseIterable, Identifiable {
    case all = "Все"
    case unwatched = "Не просмотрено"
    case watched = "Просмотрено"
    var id: Self { self }

    func predicate(searchText: String, favoritesOnly: Bool) -> Predicate<Movie> {
        let search = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let watchedOnly = self == .watched
        let unwatchedOnly = self == .unwatched
        return #Predicate<Movie> { movie in
            (search.isEmpty || movie.title.localizedStandardContains(search)
             || (movie.genre?.name.localizedStandardContains(search) ?? false))
            && (!watchedOnly || movie.isWatched)
            && (!unwatchedOnly || !movie.isWatched)
            && (!favoritesOnly || movie.isFavorite)
        }
    }
}

enum MovieSort: String, CaseIterable, Identifiable {
    case newest = "Дата добавления"
    case title = "Название"
    case year = "Год"
    case rating = "Рейтинг"
    var id: Self { self }

    var descriptors: [SortDescriptor<Movie>] {
        switch self {
        case .newest: return [SortDescriptor(\Movie.createdAt, order: .reverse)]
        case .title: return [SortDescriptor(\Movie.title), SortDescriptor(\Movie.createdAt, order: .reverse)]
        case .year: return [SortDescriptor(\Movie.year, order: .reverse), SortDescriptor(\Movie.title)]
        case .rating: return [SortDescriptor(\Movie.rating, order: .reverse), SortDescriptor(\Movie.title)]
        }
    }
}

