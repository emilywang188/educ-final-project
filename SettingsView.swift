import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: WordCastStore
    @State private var selectedInterests: Set<String> = []
    @State private var lessonLength: Int = 5

    private let lengths = [2, 5, 10]

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, 8)

                    settingsCard

                    Spacer(minLength: 120)
                }
                .padding(.horizontal, 20)
                .padding(.top, 88)
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
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Theme.outline)
                        )
                }
            }
        }
        .onAppear {
            selectedInterests = Set(store.preferences.interests)
            lessonLength = store.preferences.lessonLength
        }
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Interests")
                    .font(.system(size: 16, weight: .bold))
                ForEach(UserPreferences.availableInterests, id: \.self) { interest in
                    Toggle(isOn: binding(for: interest)) {
                        Text(interest.capitalized)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .tint(Theme.primary)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Lesson Length")
                    .font(.system(size: 16, weight: .bold))
                HStack(spacing: 8) {
                    ForEach(lengths, id: \.self) { length in
                        Button {
                            lessonLength = length
                        } label: {
                            Text("\(length) min")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(lessonLength == length ? Theme.primary : Theme.onSurfaceVariant)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(lessonLength == length ? Theme.primaryFixed : Theme.surfaceContainerLow)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            PrimaryGradientButton(title: "Save Preferences") {
                store.savePreferences(
                    UserPreferences(interests: Array(selectedInterests).sorted(), lessonLength: lessonLength)
                )
            }
            .disabled(selectedInterests.isEmpty)
            .opacity(selectedInterests.isEmpty ? 0.5 : 1)
        }
        .padding(20)
        .background(Theme.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func binding(for interest: String) -> Binding<Bool> {
        Binding(
            get: { selectedInterests.contains(interest) },
            set: { isOn in
                if isOn {
                    selectedInterests.insert(interest)
                } else {
                    selectedInterests.remove(interest)
                }
            }
        )
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WordCastStore.preview)
    }
}
