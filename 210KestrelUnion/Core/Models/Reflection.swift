import Foundation

enum MoodTag: String, Codable, CaseIterable, Identifiable {
    case calm = "Calm"
    case energetic = "Energetic"
    case stressed = "Stressed"
    case grateful = "Grateful"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .calm: return "moon.stars.fill"
        case .energetic: return "bolt.fill"
        case .stressed: return "cloud.bolt.rain.fill"
        case .grateful: return "heart.fill"
        }
    }
}

struct Reflection: Identifiable, Codable, Hashable {
    let id: UUID
    let date: Date
    let text: String
    let moodTags: [MoodTag]

    init(id: UUID = UUID(), date: Date, text: String, moodTags: [MoodTag] = []) {
        self.id = id
        self.date = date
        self.text = text
        self.moodTags = moodTags
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case text
        case moodTags
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        text = try container.decode(String.self, forKey: .text)
        moodTags = try container.decodeIfPresent([MoodTag].self, forKey: .moodTags) ?? []
    }
}
