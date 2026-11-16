import SwiftUI
import SwiftData

struct MovieRow: View {
    @Bindable var movie: Movie
    var isSelecting = false

    var body: some View {
        HStack(spacing: 12) {
            Toggle("Просмотрено: \(movie.title)", isOn: $movie.isWatched)
                .labelsHidden()
                .disabled(isSelecting)
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .strikethrough(movie.isWatched)
                Text("\(movie.genre?.name ?? "Без жанра"), \(movie.year.formatted(.number.grouping(.never)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            if movie.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.pink)
                    .accessibilityLabel("Избранное")
            }
            if movie.rating > 0 {
                Label("\(movie.rating)", systemImage: "star.fill")
                    .foregroundStyle(.orange)
                    .fixedSize()
            }
        }
        .padding(.vertical, 4)
    }
}
