import Foundation

struct ReviewScheduler {
    static func nextDate(for difficulty: ReviewDifficulty, from currentDate: Date) -> Date {
        let calendar = Calendar.current

        switch difficulty {
        case .easy:
            return calendar.date(byAdding: .day, value: 3, to: currentDate) ?? currentDate
        case .medium:
            return calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        case .hard:
            return calendar.date(byAdding: .hour, value: 4, to: currentDate) ?? currentDate
        }
    }

    static func dueItems(from items: [ReviewItem], on date: Date) -> [ReviewItem] {
        items
            .filter { $0.nextReviewDate <= date }
            .sorted { $0.nextReviewDate < $1.nextReviewDate }
    }
}
