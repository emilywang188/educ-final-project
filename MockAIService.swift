import Foundation

final class MockAIService {
    static let shared = MockAIService()

    private struct SeedWord {
        let interest: String
        let word: String
        let pronunciation: String
        let partOfSpeech: String
        let definition: String
        let tone: String
        let examples: [String]
        let tvExample: String
    }

    private let seeds: [SeedWord] = [
        SeedWord(
            interest: "academic",
            word: "cogent",
            pronunciation: "KOH-jent",
            partOfSpeech: "adjective",
            definition: "clear, logical, and convincing.",
            tone: "classroom-ready",
            examples: [
                "Her cogent summary made the research article much easier to discuss in class.",
                "The debate team won because their final point was especially cogent.",
                "A cogent thesis statement kept his essay focused from start to finish."
            ],
            tvExample: "In the study lounge, Maya shut the whole argument down with one cogent sentence and everyone just blinked."
        ),
        SeedWord(
            interest: "academic",
            word: "nuance",
            pronunciation: "NOO-ahns",
            partOfSpeech: "noun",
            definition: "a subtle difference or shade of meaning.",
            tone: "analytical",
            examples: [
                "The professor asked the class to notice the nuance in the author’s tone.",
                "Once you hear the nuance in the data, the conclusion feels more balanced.",
                "Her presentation stood out because she explained the nuance behind each result."
            ],
            tvExample: "The group chat exploded, but Jordan caught the nuance in the text and realized nobody was actually mad."
        ),
        SeedWord(
            interest: "literary",
            word: "luminous",
            pronunciation: "LOO-muh-nus",
            partOfSpeech: "adjective",
            definition: "glowing with light or marked by vivid clarity and beauty.",
            tone: "imagistic",
            examples: [
                "The writer described the city skyline as luminous after the rain.",
                "Her journal entry turned an ordinary afternoon into a luminous memory.",
                "The poem feels luminous because every image seems to shimmer."
            ],
            tvExample: "The camera cut to the rooftop and the whole scene went luminous, like the finale knew exactly what it was doing."
        ),
        SeedWord(
            interest: "literary",
            word: "wistful",
            pronunciation: "WIST-ful",
            partOfSpeech: "adjective",
            definition: "gently sad in a thoughtful or longing way.",
            tone: "reflective",
            examples: [
                "He sounded wistful when he talked about freshman year.",
                "The film ends on a wistful note instead of a dramatic one.",
                "Her caption was funny on the surface but quietly wistful underneath."
            ],
            tvExample: "At the bus stop, the soundtrack turned soft and the whole moment felt wistful without saying it out loud."
        ),
        SeedWord(
            interest: "expressive",
            word: "buoyant",
            pronunciation: "BOY-unt",
            partOfSpeech: "adjective",
            definition: "cheerful, lighthearted, and able to stay upbeat.",
            tone: "energizing",
            examples: [
                "Even after two exams, she stayed buoyant and kept the group motivated.",
                "His buoyant greeting changed the mood of the room instantly.",
                "The club’s social feed has a buoyant style that makes people want to join."
            ],
            tvExample: "You could tell the main character was buoyant because she walked into chaos like it was a victory lap."
        ),
        SeedWord(
            interest: "expressive",
            word: "vivid",
            pronunciation: "VIV-id",
            partOfSpeech: "adjective",
            definition: "producing strong, clear, and memorable images or feelings.",
            tone: "creative",
            examples: [
                "His vivid description made the internship sound like a whole mini-series.",
                "A vivid detail can make even a short story feel complete.",
                "She remembers the concert in vivid flashes of color and sound."
            ],
            tvExample: "The flashback was so vivid that everyone watching forgot it wasn’t happening in real time."
        ),
        SeedWord(
            interest: "tv/dialogue",
            word: "deadpan",
            pronunciation: "DED-pan",
            partOfSpeech: "adjective",
            definition: "showing humor or emotion with a deliberately blank expression or tone.",
            tone: "dialogue-heavy",
            examples: [
                "His deadpan reply made the whole table laugh harder.",
                "A deadpan delivery can make a simple line unforgettable.",
                "She kept reading the chaos in a deadpan voice like a seasoned host."
            ],
            tvExample: "When the roommate said, 'Great, another crisis,' in a deadpan voice, the laugh track practically wrote itself."
        ),
        SeedWord(
            interest: "tv/dialogue",
            word: "banter",
            pronunciation: "BAN-ter",
            partOfSpeech: "noun",
            definition: "playful and quick conversation that feels lively and teasing.",
            tone: "conversational",
            examples: [
                "Their banter made the presentation feel more natural than scripted.",
                "Good banter can turn a group project from awkward to fun.",
                "The podcast works because the hosts have relaxed banter."
            ],
            tvExample: "The detective and the barista traded banter so sharp it felt like the episode had switched genres for a minute."
        ),
        SeedWord(
            interest: "professional",
            word: "streamline",
            pronunciation: "STREEM-line",
            partOfSpeech: "verb",
            definition: "to make a process simpler, faster, and more efficient.",
            tone: "career-focused",
            examples: [
                "The team used a shared document to streamline communication before the event.",
                "A clean checklist can streamline even a hectic study schedule.",
                "She streamlined the meeting by sending updates ahead of time."
            ],
            tvExample: "Even the overworked startup manager had to admit the intern’s idea would streamline the whole mess."
        ),
        SeedWord(
            interest: "professional",
            word: "bandwidth",
            pronunciation: "BAND-width",
            partOfSpeech: "noun",
            definition: "the amount of time, energy, or attention available for something.",
            tone: "practical",
            examples: [
                "I want to help, but I do not have the bandwidth this week.",
                "She protected her bandwidth by blocking off study hours on her calendar.",
                "Knowing your bandwidth helps you commit to projects more honestly."
            ],
            tvExample: "By the third surprise deadline, Leo stared into the camera and said he had zero bandwidth left for nonsense."
        )
    ]

    private init() {}

    func generateDailyWord(preferences: UserPreferences, existingWords: [VocabularyWord], date: Date) -> VocabularyWord {
        let interests = preferences.interests.isEmpty ? UserPreferences.availableInterests : preferences.interests
        let candidates = seeds.filter { interests.contains($0.interest) }
        let pool = candidates.isEmpty ? seeds : candidates

        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let offset = existingWords.count
        let seed = pool[(dayIndex + offset) % pool.count]

        return buildWord(from: seed, preferences: preferences)
    }

    func randomWord(preferences: UserPreferences, existingWords: [VocabularyWord], excluding word: VocabularyWord?) -> VocabularyWord {
        let interests = preferences.interests.isEmpty ? UserPreferences.availableInterests : preferences.interests
        let candidates = seeds.filter { interests.contains($0.interest) }
        var pool = candidates.isEmpty ? seeds : candidates
        if let word {
            pool.removeAll { $0.word == word.word }
        }
        let seed = (pool.randomElement() ?? seeds.randomElement()) ?? seeds[0]
        return buildWord(from: seed, preferences: preferences)
    }

    func quizQuestion(for word: VocabularyWord, preferences: UserPreferences) -> QuizQuestion {
        let interests = preferences.interests.isEmpty ? UserPreferences.availableInterests : preferences.interests
        let candidates = seeds.filter { interests.contains($0.interest) }
        let pool = candidates.isEmpty ? seeds : candidates
        let distractors = pool.filter { $0.word != word.word }.shuffled().prefix(2).map { $0.word }
        var choices = ([word.word] + distractors)
        choices.shuffle()
        let correctIndex = choices.firstIndex(of: word.word) ?? 0
        return QuizQuestion(
            prompt: "Which word matches this definition?\n\"\(word.definition)\"",
            choices: choices,
            correctIndex: correctIndex
        )
    }

    func whyThisWord(for word: VocabularyWord, preferences: UserPreferences) -> String {
        let interestLabel = preferences.interests.isEmpty ? "your current study goals" : preferences.interests.joined(separator: ", ")
        return "This word lines up with \(interestLabel) and fits a \(preferences.lessonLength)-minute lesson, so it is useful without feeling heavy."
    }

    func wordForPreview(index: Int) -> VocabularyWord {
        buildWord(from: seeds[index % seeds.count], preferences: .default)
    }

    private func buildWord(from seed: SeedWord, preferences: UserPreferences) -> VocabularyWord {
        let transcript = """
        Welcome to WordCast. Today’s word is \(seed.word), pronounced \(seed.pronunciation). It is a \(seed.partOfSpeech) that means \(seed.definition)

        We picked this word because your interests point toward \(seed.interest) language, and this one is especially \(seed.tone). In a short \(preferences.lessonLength)-minute session, the goal is not just to memorize the definition, but to notice where the word naturally fits.

        Try hearing it in motion: \(seed.examples[0]) Then stretch it into your own life. You might use it in class, in conversation, or when describing a scene that needs more precision. Before you finish, say the word once out loud and connect it to one moment from your day.
        """

        return VocabularyWord(
            id: UUID(),
            word: seed.word,
            pronunciation: seed.pronunciation,
            partOfSpeech: seed.partOfSpeech,
            definition: seed.definition,
            examples: seed.examples,
            tvExample: seed.tvExample,
            transcript: transcript
        )
    }
}
