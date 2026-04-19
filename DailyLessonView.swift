import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var store: WordCastStore
    @State private var quizQuestion: QuizQuestion?
    @State private var selectedChoice: Int?
    @State private var quizCompleted = false
    @State private var feedback: Bool?

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    wordSection
                    podcastSection
                    quizSection
                    if quizCompleted {
                        completionSection
                    }
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
                    HStack(spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.secondary)
                            Text("Daily Streak: 12")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Theme.onSurfaceVariant)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 999)
                                .fill(Theme.surfaceContainerLow)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 999)
                                        .stroke(Theme.outlineVariant.opacity(0.4), lineWidth: 1)
                                )
                        )

                        Circle()
                            .fill(Theme.primaryFixed)
                            .frame(width: 30, height: 30)
                    }
                }
            }
        }
        .onAppear {
            store.loadTodayIfNeeded()
            if let word = store.currentLesson {
                prepareQuiz(for: word)
            }
        }
        .onChange(of: store.currentLesson?.id) { _, _ in
            if let word = store.currentLesson {
                prepareQuiz(for: word)
            }
        }
    }

    private var wordSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WORD OF THE DAY")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Theme.primary)
                .tracking(2)
                .padding(.leading, 12)

            if let word = store.currentLesson {
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(word.word.capitalized)
                            .font(.system(size: 42, weight: .black))
                            .foregroundStyle(Theme.onSurface)
                            .tracking(-1)

                        HStack(spacing: 10) {
                            Text(word.pronunciation)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.surfaceContainer)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            Text(word.partOfSpeech)
                                .font(.system(size: 12, weight: .medium))
                                .italic()
                                .foregroundStyle(Theme.onSurfaceVariant)
                        }

                        Text(word.definition)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Theme.primary)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Theme.primary)
                                Text("Why this word for you")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Theme.primary)
                                    .tracking(1.5)
                            }
                            Text(MockAIService.shared.whyThisWord(for: word, preferences: store.preferences))
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(Theme.onSurfaceVariant)
                        }
                        .padding(14)
                        .background(Theme.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            Rectangle()
                                .fill(Theme.primary.opacity(0.2))
                                .frame(width: 3),
                            alignment: .leading
                        )
                    }
                    .padding(20)

                    HStack {
                        Text("Interesting?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.onSurfaceVariant)
                        Spacer()
                        HStack(spacing: 8) {
                            feedbackButton(title: "Yes", systemImage: "hand.thumbsup.fill", isSelected: feedback == true) {
                                feedback = true
                            }
                            feedbackButton(title: "No", systemImage: "hand.thumbsdown.fill", isSelected: feedback == false) {
                                feedback = false
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Theme.surfaceContainerHighest.opacity(0.35))
                }
                .background(Theme.surfaceContainerLowest)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 14)

                Button {
                    store.randomizeCurrentLesson()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "dice.fill")
                        Text("I'm Feeling Lucky")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundStyle(Theme.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 999)
                            .stroke(Theme.outlineVariant.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            } else {
                ProgressView("Preparing today’s lesson...")
                    .frame(maxWidth: .infinity, minHeight: 260)
            }
        }
    }

    private var podcastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Audio Lesson")
                    .font(.system(size: 22, weight: .bold))
                Spacer()
                Text("New Episode")
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .foregroundStyle(Theme.secondary)
                    .background(Theme.secondaryContainer)
                    .clipShape(Capsule())
            }

            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    Button {
                        store.togglePodcastPlayback()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Theme.primaryGradient)
                                .frame(width: 56, height: 56)
                                .shadow(color: Theme.primary.opacity(0.25), radius: 12, x: 0, y: 8)
                            if store.isPodcastGenerating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: store.isPodcastPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(store.isPodcastGenerating)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("The Beauty of Transience")
                            .font(.system(size: 16, weight: .bold))
                        Text("Episode 142 • 4:20 mins")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.onSurfaceVariant)
                    }
                    Spacer()
                }

                VStack(spacing: 6) {
                    Capsule()
                        .fill(Theme.surfaceContainerHighest)
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Theme.primary)
                                .frame(width: 120, height: 6)
                        }
                    HStack {
                        Text("1:24")
                        Spacer()
                        Text("-3:06")
                    }
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.outline)
                    .tracking(1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Transcript Preview")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(Theme.outline)
                        .tracking(2)
                    Text(store.currentLesson?.transcript ?? "")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Theme.onSurfaceVariant)
                        .italic()
                        .lineLimit(3)

                    if let message = store.podcastErrorMessage {
                        Text(message)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Theme.error)
                    }
                }
                .padding(12)
                .background(Theme.surfaceContainerLowest)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Theme.outlineVariant.opacity(0.2), lineWidth: 1)
                )
            }
            .padding(16)
            .background(Theme.surfaceContainerLow)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Quiz")
                .font(.system(size: 22, weight: .bold))

            VStack(alignment: .leading, spacing: 16) {
                if let question = quizQuestion {
                    Text(question.prompt)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Theme.onSurface)

                    VStack(spacing: 10) {
                        ForEach(question.choices.indices, id: \.self) { index in
                            Button {
                                selectedChoice = index
                                quizCompleted = true
                            } label: {
                                HStack {
                                    Text(question.choices[index])
                                        .font(.system(size: 14, weight: selectedChoice == index ? .bold : .medium))
                                    Spacer()
                                    if selectedChoice != nil, index == question.correctIndex {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Theme.primary)
                                    } else if selectedChoice == index {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Theme.error)
                                    }
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity)
                                .background(selectionBackground(for: index, correctIndex: question.correctIndex))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(borderColor(for: index, correctIndex: question.correctIndex), lineWidth: selectedChoice == index || index == question.correctIndex ? 2 : 0)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if let selectedChoice {
                        Text(selectedChoice == question.correctIndex ? "Nice! You’re ready to wrap up." : "Not quite — the correct answer is highlighted.")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(selectedChoice == question.correctIndex ? Theme.primary : Theme.onSurfaceVariant)
                    }
                } else {
                    ProgressView("Preparing quiz...")
                        .frame(maxWidth: .infinity, minHeight: 120)
                }
            }
            .padding(18)
            .background(Theme.surfaceContainerHighest.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }

    private var completionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            PrimaryGradientButton(title: "Mark as Learned", systemImage: "checkmark.circle.fill") {
                store.markCurrentLessonLearned()
            }

            Text("Learning this word will add it to your Library for future review.")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.outline)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func feedbackButton(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(title == "Yes" ? Theme.secondary : Theme.error)
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Theme.surfaceContainerLow : Theme.surfaceContainerLowest)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func selectionBackground(for index: Int, correctIndex: Int) -> Color {
        guard let selectedChoice else {
            return Theme.surfaceContainerLowest
        }
        if index == correctIndex {
            return Theme.primaryFixed.opacity(0.5)
        }
        if index == selectedChoice {
            return Theme.errorContainer.opacity(0.6)
        }
        return Theme.surfaceContainerLowest
    }

    private func borderColor(for index: Int, correctIndex: Int) -> Color {
        guard let selectedChoice else { return Color.clear }
        if index == correctIndex { return Theme.primary.opacity(0.4) }
        if index == selectedChoice { return Theme.error.opacity(0.4) }
        return Color.clear
    }

    private func prepareQuiz(for word: VocabularyWord) {
        quizQuestion = MockAIService.shared.quizQuestion(for: word, preferences: store.preferences)
        selectedChoice = nil
        quizCompleted = false
        feedback = nil
    }
}

struct DailyLessonView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            TodayView()
                .environmentObject(WordCastStore.preview)
        }
    }
}
