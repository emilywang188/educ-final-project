import SwiftUI

struct ReviewView: View {
    @EnvironmentObject private var store: WordCastStore
    @State private var revealed = false

    private var dueItems: [ReviewItem] {
        store.dueReviewItems()
    }

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    progressSection

                    if let item = dueItems.first {
                        flashcardSection(item: item)
                        ratingSection(item: item)
                    } else {
                        emptyState
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
                    Circle()
                        .fill(Theme.surfaceContainerHighest)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.outline)
                        )
                }
            }
        }
    }

    private var progressSection: some View {
        let dueCount = dueItems.count
        let totalReviews = store.reviewItems.count
        let reviewedCount = totalReviews - dueCount
        let progress = totalReviews > 0 ? Double(reviewedCount) / Double(totalReviews) : 0
        
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("REVIEW PROGRESS")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.outline)
                        .tracking(1)
                    if dueCount > 0 {
                        Text("\(dueCount) Word\(dueCount == 1 ? "" : "s") Due")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.primary)
                    } else {
                        Text("All Caught Up!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Theme.secondary)
                    }
                }
                Spacer()
                if totalReviews > 0 {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.outline)
                }
            }

            if totalReviews > 0 {
                GeometryReader { geometry in
                    Capsule()
                        .fill(Theme.surfaceContainerHighest)
                        .frame(height: 10)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(Theme.primaryGradient)
                                .frame(width: geometry.size.width * CGFloat(progress), height: 10)
                        }
                }
                .frame(height: 10)
            }
        }
        .padding(20)
        .background(Theme.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 10)
    }

    private func flashcardSection(item: ReviewItem) -> some View {
        let exampleSentence = item.word.examples.first ?? ""
        let blankSentence = exampleSentence.replacingOccurrences(of: item.word.word, with: "_____", options: .caseInsensitive)
        
        return VStack(spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Text(item.word.partOfSpeech.capitalized)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.secondaryContainer)
                        .foregroundStyle(Theme.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    
                    Text(difficultyBadge(item.difficulty))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(difficultyColor(item.difficulty).opacity(0.2))
                        .foregroundStyle(difficultyColor(item.difficulty))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("DEFINITION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.primary)
                    .tracking(1.5)
                Text(item.word.definition)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.onSurface)

                if revealed {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.word.word.capitalized)
                            .font(.system(size: 32, weight: .black))
                            .foregroundStyle(Theme.primary)
                        Text(item.word.pronunciation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.onSurfaceVariant)
                    }
                    .padding(.top, 12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("EXAMPLE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Theme.outline)
                            .tracking(1.5)
                        Text("\"\(exampleSentence)\"")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(Theme.onSurfaceVariant)
                            .italic()
                    }
                    .padding(.top, 12)
                } else {
                    if !blankSentence.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("EXAMPLE")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Theme.outline)
                                .tracking(1.5)
                            Text("\"\(blankSentence)\"")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Theme.onSurfaceVariant)
                                .italic()
                        }
                        .padding(.top, 8)
                    }
                    
                    Text("Tap reveal to show the word.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.outline)
                        .padding(.top, 8)
                }
            }

            Button {
                withAnimation(.easeInOut) {
                    revealed.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: revealed ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text(revealed ? "Hide Answer" : "Reveal Answer")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Theme.primaryGradient)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(Theme.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 12)
    }
    
    private func difficultyBadge(_ difficulty: ReviewDifficulty) -> String {
        switch difficulty {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    private func difficultyColor(_ difficulty: ReviewDifficulty) -> Color {
        switch difficulty {
        case .easy: return Theme.secondary
        case .medium: return Theme.primary
        case .hard: return Theme.error
        }
    }

    private func ratingSection(item: ReviewItem) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How well did you remember this word?")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.onSurface)
                .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                RatingTile(title: "Hard", subtitle: "4 Hours", detail: "Review soon", color: Theme.error, tint: Theme.errorContainer) {
                    submit(.hard, item: item)
                }
                RatingTile(title: "Medium", subtitle: "1 Day", detail: "Tomorrow", color: Theme.primary, tint: Theme.primaryFixed.opacity(0.4)) {
                    submit(.medium, item: item)
                }
                RatingTile(title: "Easy", subtitle: "3 Days", detail: "Later", color: Theme.secondary, tint: Theme.secondaryContainer.opacity(0.5)) {
                    submit(.easy, item: item)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 54))
                .foregroundStyle(Theme.secondary)
            Text("You’re caught up")
                .font(.system(size: 22, weight: .bold))
            Text("No review cards are due right now. Learn today’s word or come back tomorrow.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Theme.onSurfaceVariant)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Theme.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func submit(_ difficulty: ReviewDifficulty, item: ReviewItem) {
        store.rateReviewItem(item, difficulty: difficulty)
        revealed = false
    }
}

private struct RatingTile: View {
    let title: String
    let subtitle: String
    let detail: String
    let color: Color
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .foregroundStyle(color)
                    .tracking(2)
                Text(subtitle)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.onSurface)
                Text(detail)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.outline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewView()
            .environmentObject(WordCastStore.preview)
    }
}
