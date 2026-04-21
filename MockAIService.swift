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
        // Theater
        SeedWord(
            interest: "Theater",
            word: "blocking",
            pronunciation: "BLOK-ing",
            partOfSpeech: "noun",
            definition: "the precise staging of actors' movements in a scene.",
            tone: "theatrical",
            examples: [
                "The director spent hours perfecting the blocking for the opening scene.",
                "Good blocking makes the stage feel alive even in a small space.",
                "She memorized her lines and blocking in one weekend."
            ],
            tvExample: "When the understudy nailed the blocking on her first try, the whole cast knew they'd found someone special."
        ),
        
        // Screenwriting
        SeedWord(
            interest: "Screenwriting",
            word: "MacGuffin",
            pronunciation: "muh-GUF-in",
            partOfSpeech: "noun",
            definition: "an object or goal that drives the plot but has little intrinsic value.",
            tone: "cinematic",
            examples: [
                "The briefcase was just a MacGuffin—what mattered was the chase itself.",
                "Hitchcock was famous for using MacGuffins to propel his thrillers.",
                "A good MacGuffin keeps the story moving without becoming the story."
            ],
            tvExample: "Everyone argued about what was in the case, but the screenwriter admitted it was just a MacGuffin to get characters in the same room."
        ),
        
        // Film production
        SeedWord(
            interest: "Film production",
            word: "continuity",
            pronunciation: "kon-tih-NOO-ih-tee",
            partOfSpeech: "noun",
            definition: "the consistency of details across different shots and scenes.",
            tone: "technical",
            examples: [
                "The script supervisor caught a continuity error before they wrapped the scene.",
                "Maintaining continuity is harder when you shoot scenes out of order.",
                "Eagle-eyed fans love spotting continuity mistakes in blockbusters."
            ],
            tvExample: "The behind-the-scenes footage showed how obsessed they were with continuity—down to the exact position of every coffee cup."
        ),
        
        // Basketball
        SeedWord(
            interest: "Basketball",
            word: "crossover",
            pronunciation: "KROS-oh-ver",
            partOfSpeech: "noun",
            definition: "a dribbling move where the ball is switched from one hand to the other.",
            tone: "athletic",
            examples: [
                "His crossover was so quick it left defenders frozen.",
                "The ankle-breaking crossover became an instant highlight reel.",
                "She practiced her crossover dribble for hours every day."
            ],
            tvExample: "When the rookie hit that crossover and the defender stumbled, the entire bench erupted."
        ),
        
        // Soccer / football
        SeedWord(
            interest: "Soccer / football",
            word: "clinical",
            pronunciation: "KLIN-ih-kul",
            partOfSpeech: "adjective",
            definition: "precise and efficient, especially in finishing scoring chances.",
            tone: "tactical",
            examples: [
                "The striker was clinical in front of goal, converting every opportunity.",
                "A clinical performance means no wasted chances.",
                "The commentator praised the team's clinical finishing in the final third."
            ],
            tvExample: "Down to ten players, they stayed clinical—one chance, one goal, game over."
        ),
        
        // Physics
        SeedWord(
            interest: "Physics",
            word: "inertia",
            pronunciation: "in-UR-shuh",
            partOfSpeech: "noun",
            definition: "the tendency of an object to resist changes in its state of motion.",
            tone: "scientific",
            examples: [
                "Newton's first law describes inertia as the resistance to acceleration.",
                "The experiment demonstrated inertia using a cart on a frictionless track.",
                "Understanding inertia helps explain why seatbelts save lives."
            ],
            tvExample: "The physics teacher used a tablecloth trick to show inertia, and half the class gasped when the dishes stayed put."
        ),
        
        // Computer science
        SeedWord(
            interest: "Computer science",
            word: "recursion",
            pronunciation: "rih-KUR-zhun",
            partOfSpeech: "noun",
            definition: "a process where a function calls itself to solve smaller instances of a problem.",
            tone: "computational",
            examples: [
                "The algorithm used recursion to traverse the entire tree structure.",
                "Understanding recursion is essential for solving many programming challenges.",
                "His code broke because the recursion had no base case."
            ],
            tvExample: "When the TA explained recursion by saying 'to understand recursion, you must first understand recursion,' everyone groaned but finally got it."
        ),
        
        // AI / machine learning
        SeedWord(
            interest: "AI / machine learning",
            word: "overfitting",
            pronunciation: "OH-ver-fit-ing",
            partOfSpeech: "noun",
            definition: "when a model learns training data too well and fails on new data.",
            tone: "technical",
            examples: [
                "The model showed signs of overfitting with 99% training accuracy but poor validation scores.",
                "Preventing overfitting requires careful regularization and cross-validation.",
                "She added dropout layers to reduce overfitting in the neural network."
            ],
            tvExample: "The AI demo looked perfect until they tested it on real users—classic overfitting, the engineer sighed."
        ),
        
        // Investing
        SeedWord(
            interest: "Investing",
            word: "diversify",
            pronunciation: "dih-VUR-sih-fy",
            partOfSpeech: "verb",
            definition: "to spread investments across different assets to reduce risk.",
            tone: "financial",
            examples: [
                "Financial advisors always recommend you diversify your portfolio.",
                "She diversified by investing in both stocks and bonds.",
                "A well-diversified portfolio weathers market volatility better."
            ],
            tvExample: "When the market crashed, the one investor who stayed calm was the one who'd actually diversified."
        ),
        
        // Startups
        SeedWord(
            interest: "Startups",
            word: "pivot",
            pronunciation: "PIV-ut",
            partOfSpeech: "verb",
            definition: "to fundamentally change business strategy or direction.",
            tone: "entrepreneurial",
            examples: [
                "After six months of poor traction, the startup decided to pivot.",
                "The best founders know when to pivot and when to persevere.",
                "Their pivot from B2C to B2B saved the company."
            ],
            tvExample: "Three weeks before launch, the CEO announced they were pivoting—half the room panicked, half got excited."
        ),
        
        // UX/UI design
        SeedWord(
            interest: "UX/UI design",
            word: "affordance",
            pronunciation: "uh-FOR-dunss",
            partOfSpeech: "noun",
            definition: "a quality of an object that suggests how it can be used.",
            tone: "design-focused",
            examples: [
                "Good buttons have visual affordances that make them obviously clickable.",
                "The handle's affordance made it clear which way to pull the door.",
                "Designers use affordances to create intuitive interfaces."
            ],
            tvExample: "The app failed because nothing had clear affordances—users just stared at the screen, confused about what to tap."
        ),
        
        // Fashion
        SeedWord(
            interest: "Fashion",
            word: "silhouette",
            pronunciation: "sil-oo-ET",
            partOfSpeech: "noun",
            definition: "the outline or general shape of something, especially clothing.",
            tone: "stylistic",
            examples: [
                "The collection featured bold silhouettes that challenged traditional proportions.",
                "A strong silhouette makes an outfit recognizable even from a distance.",
                "The designer is known for architectural silhouettes."
            ],
            tvExample: "When the model walked out in that dramatic silhouette, the entire front row leaned forward."
        ),
        
        // Cooking / culinary arts
        SeedWord(
            interest: "Cooking / culinary arts",
            word: "emulsify",
            pronunciation: "ih-MUL-sih-fy",
            partOfSpeech: "verb",
            definition: "to combine two liquids that normally don't mix, like oil and water.",
            tone: "culinary",
            examples: [
                "Whisk vigorously to emulsify the oil and vinegar into a smooth dressing.",
                "The sauce broke because it didn't emulsify properly.",
                "Learning to emulsify is fundamental to making mayonnaise."
            ],
            tvExample: "The cooking show host made it look easy: 'Just emulsify,' she said, while everyone at home watched their sauce separate."
        ),
        
        // Coffee
        SeedWord(
            interest: "Coffee",
            word: "extraction",
            pronunciation: "ek-STRAK-shun",
            partOfSpeech: "noun",
            definition: "the process of dissolving soluble compounds from coffee grounds into water.",
            tone: "precise",
            examples: [
                "Over-extraction makes coffee taste bitter and harsh.",
                "Baristas adjust grind size and brew time to perfect extraction.",
                "The ideal extraction pulls the best flavors without the unpleasant ones."
            ],
            tvExample: "The coffee snob tasted it once and said 'under-extracted'—and somehow everyone believed him."
        ),
        
        // Philosophy
        SeedWord(
            interest: "Philosophy",
            word: "empirical",
            pronunciation: "em-PEER-ih-kul",
            partOfSpeech: "adjective",
            definition: "based on observation or experience rather than theory.",
            tone: "philosophical",
            examples: [
                "The scientist demanded empirical evidence before accepting the claim.",
                "Empirical research relies on data gathered through observation.",
                "Her argument was strong theoretically but lacked empirical support."
            ],
            tvExample: "The philosophy debate got heated when someone demanded empirical proof—and the whole room realized they'd been talking in circles."
        ),
        
        // History
        SeedWord(
            interest: "History",
            word: "anachronism",
            pronunciation: "uh-NAK-ruh-niz-um",
            partOfSpeech: "noun",
            definition: "something placed in the wrong time period.",
            tone: "historical",
            examples: [
                "The movie had a glaring anachronism: wristwatches in ancient Rome.",
                "Historians love spotting anachronisms in period dramas.",
                "Using modern slang in a Renaissance novel would be a jarring anachronism."
            ],
            tvExample: "The history buffs lost it when they spotted the anachronism—electric lights in a medieval castle scene."
        ),
        
        // Gaming
        SeedWord(
            interest: "Gaming",
            word: "meta",
            pronunciation: "MET-uh",
            partOfSpeech: "noun",
            definition: "the most effective strategies or tactics currently dominating gameplay.",
            tone: "competitive",
            examples: [
                "The current meta favors aggressive early-game strategies.",
                "Pro players study the meta to stay competitive.",
                "After the patch, the entire meta shifted overnight."
            ],
            tvExample: "When the new character dropped, everyone scrambled to figure out how it changed the meta."
        ),
        
        // Travel
        SeedWord(
            interest: "Travel",
            word: "wanderlust",
            pronunciation: "WON-der-lust",
            partOfSpeech: "noun",
            definition: "a strong desire to travel and explore the world.",
            tone: "adventurous",
            examples: [
                "Her wanderlust led her to visit 30 countries before turning 25.",
                "Social media feeds full of exotic locations fuel wanderlust.",
                "The travel blog captures the spirit of wanderlust perfectly."
            ],
            tvExample: "The montage of empty roads and distant mountains hit different—pure wanderlust in 90 seconds."
        ),
        
        // TV/Dialogue
        SeedWord(
            interest: "Pop culture analysis",
            word: "trope",
            pronunciation: "TROHP",
            partOfSpeech: "noun",
            definition: "a common or overused theme, device, or cliché in storytelling.",
            tone: "analytical",
            examples: [
                "The 'chosen one' is a well-worn trope in fantasy stories.",
                "Good writers subvert familiar tropes instead of repeating them.",
                "The show avoided every tired romantic comedy trope."
            ],
            tvExample: "When the mentor character showed up, everyone knew the 'wise old guide' trope was coming—but then the show flipped it entirely."
        )
    ]

    private init() {}

    func generateDailyWord(preferences: UserPreferences, existingWords: [VocabularyWord], date: Date) -> VocabularyWord {
        // Filter seeds by matching user's actual selected interests
        let selectedInterests = Set(preferences.interests)
        let candidates = seeds.filter { selectedInterests.contains($0.interest) }
        let pool = candidates.isEmpty ? seeds : candidates

        let dayIndex = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let offset = existingWords.count
        let seed = pool[(dayIndex + offset) % pool.count]

        return buildWord(from: seed, preferences: preferences)
    }

    func randomWord(preferences: UserPreferences, existingWords: [VocabularyWord], excluding word: VocabularyWord?) -> VocabularyWord {
        // Filter seeds by matching user's actual selected interests
        let selectedInterests = Set(preferences.interests)
        let candidates = seeds.filter { selectedInterests.contains($0.interest) }
        var pool = candidates.isEmpty ? seeds : candidates
        if let word {
            pool.removeAll { $0.word == word.word }
        }
        let seed = (pool.randomElement() ?? seeds.randomElement()) ?? seeds[0]
        return buildWord(from: seed, preferences: preferences)
    }

    func quizQuestion(for word: VocabularyWord, preferences: UserPreferences) -> QuizQuestion {
        // Use all available seeds for maximum variety
        let allSeeds = seeds.filter { $0.word != word.word }.shuffled()
        
        // Get the correct sentence from the target word's examples
        let correctSentence = word.examples.randomElement() ?? word.examples[0]
        
        // Create distractor sentences by trying to swap words from other examples
        var sentenceChoices: [String] = [correctSentence]
        
        for seed in allSeeds {
            if sentenceChoices.count >= 3 { break }
            
            // Try each example from this seed
            for distractorExample in seed.examples {
                if sentenceChoices.count >= 3 { break }
                
                // Replace the seed word with our target word (case insensitive)
                var incorrectSentence = distractorExample
                
                // Try to find and replace the word in various forms
                let pattern = "\\b\(NSRegularExpression.escapedPattern(for: seed.word))\\b"
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(distractorExample.startIndex..., in: distractorExample)
                    incorrectSentence = regex.stringByReplacingMatches(
                        in: distractorExample,
                        options: [],
                        range: range,
                        withTemplate: word.word
                    )
                }
                
                // Only add if replacement worked and it's unique
                if incorrectSentence != distractorExample && 
                   !sentenceChoices.contains(incorrectSentence) {
                    sentenceChoices.append(incorrectSentence)
                }
            }
        }
        
        sentenceChoices.shuffle()
        let correctIndex = sentenceChoices.firstIndex(of: correctSentence) ?? 0
        
        return QuizQuestion(
            prompt: "Which sentence uses \"\(word.word)\" correctly?",
            choices: sentenceChoices,
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
        Welcome to WordCast. I'm excited to dive into today's word with you. Let's explore \(seed.word), pronounced \(seed.pronunciation). It's a \(seed.partOfSpeech) that means \(seed.definition)

        Now, you might be wondering why we picked this particular word for you today. Well, your interests point toward \(seed.interest), and this word is especially \(seed.tone) in that domain. It's one of those terms that can really elevate how you communicate in this space.

        Let me paint a picture of how this word works in real contexts. \(seed.examples[0]) Notice how naturally it fits there? Here's another angle: \(seed.examples[1]) And one more to really cement it: \(seed.examples[2])

        But here's where it gets interesting. \(seed.tvExample) That example shows you the word in action, capturing not just what it means, but the feeling and context around it.

        Now, the key to making this word stick isn't just about memorizing the definition. It's about finding those moments in your own life where this word belongs. Think about your conversations, your work, your studies. Where could \(seed.word) add clarity or precision? Maybe you're describing a situation to a friend, writing an essay, or just trying to articulate a thought more precisely.

        Here's a challenge for you: before the day ends, try to use \(seed.word) in a sentence. It doesn't have to be out loud—you can write it down, text it to someone, or just practice it in your head. The act of creating your own example will make this word truly yours.

        To wrap up, let's review quickly. \(seed.word), \(seed.pronunciation), means \(seed.definition). Remember those examples we talked about, and most importantly, connect this word to something real in your world. That's how vocabulary becomes part of who you are, not just what you know.

        Thanks for learning with me today. See you next time on WordCast.
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
