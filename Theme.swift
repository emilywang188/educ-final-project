import SwiftUI

enum Theme {
    static let primary = Color(red: 0.14, green: 0.22, blue: 0.61) // #23379B
    static let primaryContainer = Color(red: 0.24, green: 0.31, blue: 0.71) // #3E50B4
    static let primaryFixed = Color(red: 0.87, green: 0.88, blue: 1.00) // #DEE0FF
    static let onPrimaryFixed = Color(red: 0.00, green: 0.06, blue: 0.36) // #00105C

    static let secondary = Color(red: 0.17, green: 0.41, blue: 0.34) // #2C6956
    static let secondaryContainer = Color(red: 0.68, green: 0.93, blue: 0.83) // #AEEDD5

    static let error = Color(red: 0.73, green: 0.10, blue: 0.10) // #BA1A1A
    static let errorContainer = Color(red: 1.00, green: 0.85, blue: 0.84) // #FFDAD6

    static let background = Color(red: 0.98, green: 0.97, blue: 1.00) // #FBF8FF
    static let surface = background
    static let surfaceContainerLowest = Color.white
    static let surfaceContainerLow = Color(red: 0.96, green: 0.95, blue: 0.99) // #F5F2FC
    static let surfaceContainer = Color(red: 0.94, green: 0.93, blue: 0.96) // #EFEDF6
    static let surfaceContainerHigh = Color(red: 0.91, green: 0.91, blue: 0.94) // #E9E7F0
    static let surfaceContainerHighest = Color(red: 0.89, green: 0.88, blue: 0.92) // #E3E1EA

    static let outline = Color(red: 0.46, green: 0.46, blue: 0.52) // #757684
    static let outlineVariant = Color(red: 0.77, green: 0.77, blue: 0.83) // #C5C5D4

    static let onSurface = Color(red: 0.10, green: 0.11, blue: 0.13) // #1A1B22
    static let onSurfaceVariant = Color(red: 0.27, green: 0.27, blue: 0.32) // #454652

    static var primaryGradient: LinearGradient {
        LinearGradient(colors: [primary, primaryContainer], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var glassBackground: Color {
        Color.white.opacity(0.8)
    }
}
