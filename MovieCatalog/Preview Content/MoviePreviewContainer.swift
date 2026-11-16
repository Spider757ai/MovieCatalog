import SwiftData

@MainActor
let moviePreviewContainer: ModelContainer = {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    do {
        let container = try ModelContainer(for: Movie.self, Genre.self, configurations: configuration)
        let fiction = Genre(name: "Фантастика")
        let animation = Genre(name: "Анимация")
        container.mainContext.insert(fiction)
        container.mainContext.insert(animation)
        container.mainContext.insert(Movie(title: "Прибытие", year: 2016, genre: fiction,
                                           isWatched: true, rating: 5, isFavorite: true))
        container.mainContext.insert(Movie(title: "Унесённые призраками", year: 2001, genre: animation))
        container.mainContext.insert(Movie(title: "Интерстеллар", year: 2014, genre: fiction,
                                           isWatched: true, rating: 4))
        return container
    } catch {
        fatalError("Preview container error: \(error)")
    }
}()
