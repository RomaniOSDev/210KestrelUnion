import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let details: String
    let symbol: String
    let isUnlocked: Bool
    let unlockedAt: Date?
}
