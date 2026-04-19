import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: WordCastStore
    @State private var selectedInterests: Set<String> = []
    @State private var customInterests: [String] = []
    @State private var newCustomInterest: String = ""
    @State private var expandedSections: Set<String> = []

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    interestsCard
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
            let savedInterests = store.preferences.interests
            selectedInterests = Set(savedInterests.filter { UserPreferences.availableInterests.contains($0) })
            customInterests = savedInterests.filter { !UserPreferences.availableInterests.contains($0) }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.system(size: 32, weight: .bold))
            Text("Accordion categories · tap chips to add")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Theme.onSurfaceVariant)
        }
        .padding(.top, 8)
    }
    
    private var totalSelectedCount: Int {
        selectedInterests.count + customInterests.count
    }

    private var interestsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Interests")
                        .font(.system(size: 20, weight: .bold))
                    Text("We'll write your daily podcast around these.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Theme.onSurfaceVariant)
                }
                Spacer()
                Text("\(totalSelectedCount) selected")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.onSurfaceVariant)
            }
            
            ForEach(UserPreferences.interestSections) { section in
                accordionSection(for: section)
            }
            
            otherSection
        }
        .padding(20)
        .background(Theme.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private func accordionSection(for section: UserPreferences.InterestSection) -> some View {
        let sectionSelectedCount = section.items.filter { selectedInterests.contains($0) }.count
        let isExpanded = expandedSections.contains(section.id)
        
        return VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    if isExpanded {
                        expandedSections.remove(section.id)
                    } else {
                        expandedSections.insert(section.id)
                    }
                }
            } label: {
                HStack {
                    Text(section.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.onSurface)
                    
                    if sectionSelectedCount > 0 {
                        Text("\(sectionSelectedCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Theme.onSurfaceVariant)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.surfaceContainerHigh)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.onSurfaceVariant)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Theme.surfaceContainerLow)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                FlowLayout(spacing: 8) {
                    ForEach(section.items, id: \.self) { interest in
                        interestChip(interest: interest)
                    }
                }
                .padding(.horizontal, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func interestChip(interest: String) -> some View {
        let isSelected = selectedInterests.contains(interest)
        
        return Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                if isSelected {
                    selectedInterests.remove(interest)
                } else {
                    selectedInterests.insert(interest)
                }
                savePreferences()
            }
        } label: {
            HStack(spacing: 6) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                Text(interest)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? .white : Theme.onSurface)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(isSelected ? Theme.primary : Theme.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? Color.clear : Theme.outline.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Other")
                    .font(.system(size: 16, weight: .semibold))
                Text("Add anything else — a niche, a person, a keyword.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Theme.onSurfaceVariant)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            HStack(spacing: 8) {
                TextField("Type an interest...", text: $newCustomInterest)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Theme.surfaceContainerLowest)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.outline.opacity(0.2), lineWidth: 1)
                    )
                
                Button {
                    addCustomInterest()
                } label: {
                    Text("Add")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Theme.primary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Theme.primaryContainer.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(newCustomInterest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(newCustomInterest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
            .padding(.horizontal, 16)
            
            if !customInterests.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(customInterests, id: \.self) { interest in
                        customInterestChip(interest: interest)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(Theme.surfaceContainerLow)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func customInterestChip(interest: String) -> some View {
        HStack(spacing: 6) {
            Text(interest)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.onSurface)
            
            Button {
                removeCustomInterest(interest)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Theme.onSurfaceVariant)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Theme.outline.opacity(0.3), lineWidth: 1)
        )
    }
    
    private func addCustomInterest() {
        let trimmed = newCustomInterest.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !customInterests.contains(trimmed) else { return }
        
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            customInterests.append(trimmed)
            newCustomInterest = ""
            savePreferences()
        }
    }
    
    private func removeCustomInterest(_ interest: String) {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
            customInterests.removeAll { $0 == interest }
            savePreferences()
        }
    }
    
    private func savePreferences() {
        let allInterests = UserPreferences.orderedInterests(from: selectedInterests) + customInterests
        store.savePreferences(
            UserPreferences(
                interests: allInterests,
                lessonLength: store.preferences.lessonLength
            )
        )
    }
}

// Flow layout for wrapping chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(WordCastStore.preview)
    }
}
