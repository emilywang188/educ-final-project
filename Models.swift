import Foundation
import SwiftUI

struct UserPreferences: Codable, Equatable {
    var interests: [String]
    var lessonLength: Int

    static let availableInterests = ["academic", "expressive", "literary", "tv/dialogue", "professional"]

    static let `default` = UserPreferences(
        interests: ["academic", "expressive"],
        lessonLength: 5
    )
}

struct VocabularyWord: Identifiable, Codable, Hashable {
    let id: UUID
    let word: String
    let pronunciation: String
    let partOfSpeech: String
    let definition: String
    let examples: [String]
    let tvExample: String
    let transcript: String
}

enum ReviewDifficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
}

struct ReviewItem: Identifiable, Codable, Hashable {
    var id: UUID { word.id }
    let word: VocabularyWord
    var nextReviewDate: Date
    var difficulty: ReviewDifficulty
}

struct QuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let choices: [String]
    let correctIndex: Int
}

@MainActor
final class WordCastStore: ObservableObject {
    @Published var preferences: UserPreferences
    @Published var hasCompletedOnboarding: Bool
    @Published var currentLesson: VocabularyWord?
    @Published var library: [VocabularyWord]
    @Published var reviewItems: [ReviewItem]
    @Published var favoriteWordIDs: Set<UUID>
    @Published var learnedWordIDs: Set<UUID>
    @Published var isPodcastPlaying = false

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private enum Keys {
        static let preferences = "wordcast.preferences"
        static let didCompleteOnboarding = "wordcast.didCompleteOnboarding"
        static let currentLesson = "wordcast.currentLesson"
        static let currentLessonDate = "wordcast.currentLessonDate"
        static let library = "wordcast.library"
        static let reviewItems = "wordcast.reviewItems"
        static let favoriteWordIDs = "wordcast.favoriteWordIDs"
        static let learnedWordIDs = "wordcast.learnedWordIDs"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.preferences = Self.decode(UserPreferences.self, key: Keys.preferences, defaults: defaults) ?? .default
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.didCompleteOnboarding)
        self.currentLesson = Self.decode(VocabularyWord.self, key: Keys.currentLesson, defaults: defaults)
        self.library = Self.decode([VocabularyWord].self, key: Keys.library, defaults: defaults) ?? []
        self.reviewItems = Self.decode([ReviewItem].self, key: Keys.reviewItems, defaults: defaults) ?? []
        self.favoriteWordIDs = Set(Self.decode([UUID].self, key: Keys.favoriteWordIDs, defaults: defaults) ?? [])
        self.learnedWordIDs = Set(Self.decode([UUID].self, key: Keys.learnedWordIDs, defaults: defaults) ?? [])
    }

    func completeOnboarding(with preferences: UserPreferences) {
        savePreferences(preferences)
        hasCompletedOnboarding = true
        defaults.set(true, forKey: Keys.didCompleteOnboarding)
        loadTodayIfNeeded(forceRefresh: true)
    }

    func savePreferences(_ preferences: UserPreferences) {
        self.preferences = preferences
        persist(preferences, key: Keys.preferences)
        loadTodayIfNeeded(forceRefresh: true)
    }

    func loadTodayIfNeeded(forceRefresh: Bool = false) {
        guard hasCompletedOnboarding else { return }

        let storedDate = defaults.object(forKey: Keys.currentLessonDate) as? Date ?? .distantPast
        let isSameDay = Calendar.current.isDate(storedDate, inSameDayAs: Date())

        if !forceRefresh, isSameDay, currentLesson != nil {
            return
        }

        let lesson = MockAIService.shared.generateDailyWord(
            preferences: preferences,
            existingWords: library,
            date: Date()
        )
        currentLesson = lesson
        isPodcastPlaying = false
        persist(lesson, key: Keys.currentLesson)
        defaults.set(Date(), forKey: Keys.currentLessonDate)

        if !library.contains(lesson) {
            library.insert(lesson, at: 0)
            persist(library, key: Keys.library)
        }
    }

    func randomizeCurrentLesson() {
        guard hasCompletedOnboarding else { return }
        let previousLesson = currentLesson
        let lesson = MockAIService.shared.randomWord(
            preferences: preferences,
            existingWords: library,
            excluding: currentLesson
        )
        currentLesson = lesson
        isPodcastPlaying = false
        persist(lesson, key: Keys.currentLesson)
        defaults.set(Date(), forKey: Keys.currentLessonDate)

        if let previousLesson {
            library.removeAll { $0.id == previousLesson.id }
        }
        if !library.contains(lesson) {
            library.insert(lesson, at: 0)
        }
        persist(library, key: Keys.library)
    }

    func togglePodcastPlayback() {
        isPodcastPlaying.toggle()
    }

    var isCurrentLessonFavorite: Bool {
        guard let currentLesson else { return false }
        return favoriteWordIDs.contains(currentLesson.id)
    }

    var isCurrentLessonLearned: Bool {
        guard let currentLesson else { return false }
        return learnedWordIDs.contains(currentLesson.id)
    }

    func toggleFavoriteCurrentLesson() {
        guard let currentLesson else { return }
        toggleFavorite(currentLesson)
    }

    func toggleFavorite(_ word: VocabularyWord) {
        if favoriteWordIDs.contains(word.id) {
            favoriteWordIDs.remove(word.id)
        } else {
            favoriteWordIDs.insert(word.id)
        }
        persist(Array(favoriteWordIDs), key: Keys.favoriteWordIDs)
    }

    func isFavorite(_ word: VocabularyWord) -> Bool {
        favoriteWordIDs.contains(word.id)
    }

    func markCurrentLessonLearned() {
        guard let currentLesson else { return }
        learnedWordIDs.insert(currentLesson.id)
        persist(Array(learnedWordIDs), key: Keys.learnedWordIDs)
        scheduleReview(for: currentLesson, difficulty: .medium)
    }

    func scheduleReview(for word: VocabularyWord, difficulty: ReviewDifficulty) {
        let nextDate = ReviewScheduler.nextDate(for: difficulty, from: Date())

        if let index = reviewItems.firstIndex(where: { $0.word.id == word.id }) {
            reviewItems[index].difficulty = difficulty
            reviewItems[index].nextReviewDate = nextDate
        } else {
            reviewItems.append(
                ReviewItem(word: word, nextReviewDate: nextDate, difficulty: difficulty)
            )
        }

        reviewItems.sort { $0.nextReviewDate < $1.nextReviewDate }
        persist(reviewItems, key: Keys.reviewItems)
    }

    func dueReviewItems() -> [ReviewItem] {
        ReviewScheduler.dueItems(from: reviewItems, on: Date())
    }

    func rateReviewItem(_ item: ReviewItem, difficulty: ReviewDifficulty) {
        guard let index = reviewItems.firstIndex(where: { $0.word.id == item.word.id }) else { return }
        reviewItems[index].difficulty = difficulty
        reviewItems[index].nextReviewDate = ReviewScheduler.nextDate(for: difficulty, from: Date())
        reviewItems.sort { $0.nextReviewDate < $1.nextReviewDate }
        persist(reviewItems, key: Keys.reviewItems)
    }

    private func persist<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private static func decode<T: Decodable>(_ type: T.Type, key: String, defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

extension WordCastStore {
    static var preview: WordCastStore {
        let defaults = UserDefaults(suiteName: "wordcast.preview.main")!
        defaults.removePersistentDomain(forName: "wordcast.preview.main")
        let store = WordCastStore(defaults: defaults)
        store.hasCompletedOnboarding = true
        store.preferences = UserPreferences(interests: ["academic", "literary", "professional"], lessonLength: 5)
        store.currentLesson = MockAIService.shared.generateDailyWord(preferences: store.preferences, existingWords: [], date: Date())
        if let currentLesson = store.currentLesson {
            store.library = [
                currentLesson,
                MockAIService.shared.wordForPreview(index: 3),
                MockAIService.shared.wordForPreview(index: 6)
            ]
            store.favoriteWordIDs = [currentLesson.id]
            store.reviewItems = [
                ReviewItem(word: currentLesson, nextReviewDate: .now.addingTimeInterval(-60), difficulty: .medium),
                ReviewItem(word: MockAIService.shared.wordForPreview(index: 1), nextReviewDate: .now.addingTimeInterval(7200), difficulty: .easy)
            ]
            store.learnedWordIDs = [currentLesson.id]
        }
        return store
    }

    static var previewOnboarding: WordCastStore {
        let defaults = UserDefaults(suiteName: "wordcast.preview.onboarding")!
        defaults.removePersistentDomain(forName: "wordcast.preview.onboarding")
        let store = WordCastStore(defaults: defaults)
        store.hasCompletedOnboarding = false
        return store
    }
}
