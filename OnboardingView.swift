import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: WordCastStore
    @State private var selectedInterests: Set<String> = []

    private let sectionIcons: [String: String] = [
        "Performing Arts & Entertainment": "theatermasks.fill",
        "Sports & Athletics": "sportscourt.fill",
        "Science & Technical Domains": "atom",
        "Business, Finance & Economics": "briefcase.fill",
        "Creative & Design Fields": "paintpalette.fill",
        "Lifestyle & Hobbies": "leaf.fill",
        "Culture, Society & Identity": "book.fill",
        "Niche & Subculture Interests": "sparkles"
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    hero
                    interestSection
                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
            .padding(.top, 70)

            decorativeRing

            footer
        }
        .background(Theme.background)
        .overlay(alignment: .top) {
            GlassHeader {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WordCast")
                        .font(.system(size: 20, weight: .black))
                        .foregroundStyle(Theme.primary)
                        .tracking(-0.5)
                    Text("VOCABULARY BUILDER")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.outline)
                        .tracking(1.5)
                }
            } trailing: {
                Circle()
                    .fill(Theme.surfaceContainerHighest)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.outline)
                    )
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selectedInterests = Set(store.preferences.interests.filter { UserPreferences.availableInterests.contains($0) })
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shape your\nlexicon.")
                .font(.system(size: 48, weight: .black))
                .foregroundStyle(Theme.onSurface)
                .tracking(-1)
            Text("Welcome to the atelier. Let’s personalize your linguistic journey through curated exploration.")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(Theme.onSurfaceVariant)
        }
    }

    private var interestSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Interests")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text("SELECT MANY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.primary)
                    .tracking(2)
            }

            VStack(alignment: .leading, spacing: 16) {
                ForEach(UserPreferences.interestSections) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(section.title)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Theme.onSurfaceVariant)

                        FlexibleChipGrid(items: section.items) { interest in
                            Button {
                                toggle(interest)
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: icon(for: interest, sectionTitle: section.title))
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(interest)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .foregroundStyle(selectedInterests.contains(interest) ? Theme.onPrimaryFixed : Theme.onSurfaceVariant)
                                .background(selectedInterests.contains(interest) ? Theme.primaryFixed : Theme.surfaceContainerHigh)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .shadow(color: Color.black.opacity(selectedInterests.contains(interest) ? 0.06 : 0), radius: 10, x: 0, y: 6)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var decorativeRing: some View {
        Circle()
            .stroke(Theme.primary, lineWidth: 30)
            .frame(width: 220, height: 220)
            .opacity(0.08)
            .rotationEffect(.degrees(-12))
            .offset(x: 140, y: 40)
            .allowsHitTesting(false)
    }

    private var footer: some View {
        VStack(spacing: 10) {
            PrimaryGradientButton(title: "Start Learning", systemImage: "arrow.right") {
                let preferences = UserPreferences(
                    interests: UserPreferences.orderedInterests(from: selectedInterests),
                    lessonLength: store.preferences.lessonLength
                )
                store.completeOnboarding(with: preferences)
            }
            .disabled(selectedInterests.isEmpty)
            .opacity(selectedInterests.isEmpty ? 0.5 : 1)

            Text("STEP 1 OF 3 — PERSONALIZATION")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Theme.outline)
                .tracking(2)
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(Theme.glassBackground)
        .background(.ultraThinMaterial)
    }

    private func toggle(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else {
            selectedInterests.insert(interest)
        }
    }

    private func icon(for interest: String, sectionTitle: String) -> String {
        if interest == "Esports" || interest == "Gaming" {
            return "gamecontroller.fill"
        }
        return sectionIcons[sectionTitle] ?? "sparkles"
    }
}

private struct FlexibleChipGrid<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    init(items: [Item], @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OnboardingView()
                .environmentObject(WordCastStore.previewOnboarding)
        }
    }
}
