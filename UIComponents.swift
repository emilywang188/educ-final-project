import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case review
    case library
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .review: return "Review"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .today: return "calendar"
        case .review: return "clock.arrow.circlepath"
        case .library: return "books.vertical"
        case .settings: return "gearshape"
        }
    }
}

struct GlassHeader<Leading: View, Trailing: View>: View {
    let leading: Leading
    let trailing: Trailing

    init(@ViewBuilder leading: () -> Leading, @ViewBuilder trailing: () -> Trailing) {
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center) {
            leading
            Spacer()
            trailing
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Theme.glassBackground)
        .background(.ultraThinMaterial)
        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.04))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

struct PrimaryGradientButton: View {
    let title: String
    let systemImage: String?
    let action: () -> Void

    init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .foregroundStyle(.white)
            .background(Theme.primaryGradient)
            .clipShape(Capsule())
            .shadow(color: Theme.primary.opacity(0.25), radius: 14, x: 0, y: 8)
        }
        .buttonStyle(.plain)
    }
}

struct GlassTabBar: View {
    @Binding var selection: AppTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    selection = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.systemImage)
                            .font(.system(size: 16, weight: selection == tab ? .bold : .regular))
                            .symbolVariant(selection == tab ? .fill : .none)
                        Text(tab.title)
                            .font(.system(size: 10, weight: selection == tab ? .bold : .medium))
                            .textCase(.uppercase)
                            .tracking(1)
                    }
                    .foregroundStyle(selection == tab ? Theme.primary : Theme.outline)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selection == tab ? Theme.primaryFixed.opacity(0.7) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Theme.glassBackground)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: -6)
    }
}
