import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var store: WordCastStore
    @State private var searchText = ""
    @State private var selectedFilter = "All Words"

    private let filters = ["All Words", "Favorites", "Recently Learned", "Nouns"]

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    filterChips
                    wordList
                    loadMore
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 88)
                .padding(.bottom, 32)
            }
            .overlay(alignment: .top) {
                GlassHeader {
                    HStack(spacing: 10) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Theme.primary)
                        Text("WordCast")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(Theme.primary)
                            .tracking(-0.5)
                    }
                } trailing: {
                    Circle()
                        .fill(Theme.primaryFixed)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.outline)
                        )
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR COLLECTION")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Theme.primary)
                .tracking(2)
            Text("Library")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(Theme.onSurface)

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.outline)
                TextField("Search your lexicon...", text: $searchText)
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(Theme.surfaceContainerHighest)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selectedFilter == filter ? .white : Theme.onSurfaceVariant)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? Theme.primary : Theme.surfaceContainerHigh)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var wordList: some View {
        VStack(spacing: 12) {
            if store.library.isEmpty {
                ContentUnavailableView(
                    "No saved words yet",
                    systemImage: "books.vertical",
                    description: Text("Mark a daily lesson as learned to build your library.")
                )
            } else {
                ForEach(store.library) { word in
                    NavigationLink {
                        LibraryDetailView(word: word)
                            .environmentObject(store)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(word.word.capitalized)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundStyle(Theme.onSurface)
                                    Text(word.partOfSpeech.prefix(3).uppercased())
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Theme.outline)
                                        .tracking(1)
                                }
                                Text(word.definition)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Theme.onSurfaceVariant)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button {
                                store.toggleFavorite(word)
                            } label: {
                                Image(systemName: store.isFavorite(word) ? "star.fill" : "star")
                                    .foregroundStyle(store.isFavorite(word) ? Theme.secondary : Theme.outline)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Theme.outlineVariant)
                        }
                        .padding(16)
                        .background(Theme.surfaceContainerLowest)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var loadMore: some View {
        HStack {
            Spacer()
            Button {
            } label: {
                HStack(spacing: 6) {
                    Text("Load more words")
                    Image(systemName: "chevron.down")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.primary)
                .tracking(1)
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.top, 8)
    }
}

private struct LibraryDetailView: View {
    @EnvironmentObject private var store: WordCastStore
    @Environment(\.dismiss) private var dismiss
    let word: VocabularyWord

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(word.word.capitalized)
                        .font(.system(size: 34, weight: .bold))
                    Text(word.pronunciation)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.onSurfaceVariant)
                    Text(word.definition)
                        .font(.system(size: 18, weight: .medium))

                    Text("Transcript")
                        .font(.system(size: 14, weight: .bold))
                    Text(word.transcript)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Theme.onSurfaceVariant)

                    Button {
                        store.toggleFavorite(word)
                    } label: {
                        Text(store.isFavorite(word) ? "Remove Favorite" : "Favorite Word")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.surfaceContainerLow)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 88)
            }
            .overlay(alignment: .top) {
                GlassHeader {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Theme.primary)
                    }
                    .buttonStyle(.plain)
                } trailing: {
                    Text(word.word.capitalized)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(Theme.onSurface)
                }
            }
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LibraryView()
                .environmentObject(WordCastStore.preview)
        }
    }
}
