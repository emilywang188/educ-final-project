import Foundation
import SwiftUI

struct UserPreferences: Codable, Equatable {
    var interests: [String]
    var lessonLength: Int

    struct InterestSection: Identifiable, Hashable {
        let id: String
        let title: String
        let items: [String]
    }

    static let interestSections: [InterestSection] = [
        InterestSection(
            id: "performing-arts-entertainment",
            title: "Performing Arts & Entertainment",
            items: [
                "Theater",
                "Musical theater",
                "Opera",
                "Orchestra / symphony",
                "Film production",
                "Screenwriting",
                "Acting techniques",
                "Stand-up comedy",
                "Dance"
            ]
        ),
        InterestSection(
            id: "sports-athletics",
            title: "Sports & Athletics",
            items: [
                "Soccer / football",
                "Basketball",
                "Baseball",
                "American football",
                "Combat sports",
                "Endurance sports",
                "Strength training",
                "Esports"
            ]
        ),
        InterestSection(
            id: "science-technical",
            title: "Science & Technical Domains",
            items: [
                "Physics",
                "Biology",
                "Medicine",
                "Computer science",
                "AI / machine learning",
                "Astronomy",
                "Engineering"
            ]
        ),
        InterestSection(
            id: "business-finance-econ",
            title: "Business, Finance & Economics",
            items: [
                "Investing",
                "Startups",
                "Corporate strategy",
                "Real estate",
                "Marketing",
                "Supply chain"
            ]
        ),
        InterestSection(
            id: "creative-design",
            title: "Creative & Design Fields",
            items: [
                "Graphic design",
                "UX/UI design",
                "Fashion",
                "Interior design",
                "Architecture",
                "Photography"
            ]
        ),
        InterestSection(
            id: "lifestyle-hobbies",
            title: "Lifestyle & Hobbies",
            items: [
                "Cooking / culinary arts",
                "Coffee",
                "Wine",
                "Fitness & wellness",
                "Travel",
                "Gardening",
                "DIY / crafting"
            ]
        ),
        InterestSection(
            id: "culture-society-identity",
            title: "Culture, Society & Identity",
            items: [
                "Philosophy",
                "Religion / spirituality",
                "History",
                "Sociology",
                "Linguistics",
                "Pop culture analysis"
            ]
        ),
        InterestSection(
            id: "niche-subculture",
            title: "Niche & Subculture Interests",
            items: [
                "Cars / motorsports",
                "Watches / horology",
                "Gaming",
                "Collecting",
                "Urban exploration",
                "Outdoors / survival",
                "Magic / illusion"
            ]
        )
    ]

    static let availableInterests = interestSections.flatMap(\.items)

    static let `default` = UserPreferences(
        interests: ["Computer science", "Philosophy"],
        lessonLength: 5
    )

    static func orderedInterests(from selected: Set<String>) -> [String] {
        let selectedSet = selected
        return availableInterests.filter { selectedSet.contains($0) }
    }

    enum SeedInterest: String, CaseIterable {
        case academic
        case expressive
        case literary
        case tvDialogue = "tv/dialogue"
        case professional
    }

    static func seedInterestKeys(from selected: [String]) -> [String] {
        let trimmed = selected.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let selectedSet = Set(trimmed)
        if selectedSet.isEmpty {
            return SeedInterest.allCases.map(\.rawValue)
        }

        var mapped: Set<SeedInterest> = []
        for interest in selectedSet {
            if let seed = SeedInterest(rawValue: interest) {
                mapped.insert(seed)
                continue
            }
            if let seed = seedInterestOverrides[interest] {
                mapped.insert(seed)
                continue
            }
            if let sectionTitle = sectionTitleByItem[interest], let seed = seedInterestBySectionTitle[sectionTitle] {
                mapped.insert(seed)
                continue
            }
            mapped.insert(.expressive)
        }

        if mapped.isEmpty {
            return SeedInterest.allCases.map(\.rawValue)
        }

        return mapped.map(\.rawValue).sorted()
    }

    private static let sectionTitleByItem: [String: String] = {
        var map: [String: String] = [:]
        for section in interestSections {
            for item in section.items {
                map[item] = section.title
            }
        }
        return map
    }()

    private static let seedInterestBySectionTitle: [String: SeedInterest] = [
        "Performing Arts & Entertainment": .expressive,
        "Sports & Athletics": .expressive,
        "Science & Technical Domains": .academic,
        "Business, Finance & Economics": .professional,
        "Creative & Design Fields": .expressive,
        "Lifestyle & Hobbies": .expressive,
        "Culture, Society & Identity": .academic,
        "Niche & Subculture Interests": .tvDialogue
    ]

    private static let seedInterestOverrides: [String: SeedInterest] = [
        "Film production": .tvDialogue,
        "Screenwriting": .tvDialogue,
        "Stand-up comedy": .tvDialogue,
        "Esports": .tvDialogue,
        "Pop culture analysis": .tvDialogue,
        "Gaming": .tvDialogue
    ]
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
    @Published var isPodcastGenerating = false
    @Published var podcastErrorMessage: String?

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let podcastService = GeminiPodcastService()
    private let podcastPlayer = PodcastAudioPlayer()
    private var cachedPodcastURLByWordID: [UUID: URL] = [:]

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
        isPodcastGenerating = false
        podcastErrorMessage = nil
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
        isPodcastGenerating = false
        podcastErrorMessage = nil
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
        Task { await togglePodcastPlaybackAsync() }
    }

    private func togglePodcastPlaybackAsync() async {
        podcastErrorMessage = nil

        if isPodcastPlaying || podcastPlayer.isPlaying {
            podcastPlayer.stop()
            isPodcastPlaying = false
            isPodcastGenerating = false
            return
        }

        guard let lesson = currentLesson else { return }
        guard !isPodcastGenerating else { return }
        isPodcastGenerating = true

        do {
            let audioURL: URL
            if let cached = cachedPodcastURLByWordID[lesson.id] {
                audioURL = cached
            } else {
                audioURL = try await podcastService.generatePodcastWav(text: lesson.transcript)
                cachedPodcastURLByWordID[lesson.id] = audioURL
            }

            try podcastPlayer.play(url: audioURL) { [weak self] in
                Task { @MainActor in
                    self?.isPodcastPlaying = false
                }
            }

            isPodcastPlaying = true
        } catch {
            podcastErrorMessage = error.localizedDescription
            isPodcastPlaying = false
        }

        isPodcastGenerating = false
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
        store.preferences = UserPreferences(interests: ["Computer science", "Marketing", "Theater"], lessonLength: 5)
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
