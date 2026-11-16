import Foundation
import SwiftData

@Model
final class Movie {
    var title: String
    var year: Int
    var genre: Genre?
    var isWatched: Bool
    var rating: Int
    var isFavorite: Bool
    var createdAt: Date

    init(title: String, year: Int, genre: Genre?, isWatched: Bool = false,
         rating: Int = 0, isFavorite: Bool = false, createdAt: Date = .now) {
        self.title = title
        self.year = year
        self.genre = genre
        self.isWatched = isWatched
        self.rating = rating
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}
