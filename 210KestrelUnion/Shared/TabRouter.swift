import Combine
import Foundation

final class TabRouter: ObservableObject {
    @Published var selectedTab: RootTab = .reflections

    func open(_ tab: RootTab) {
        selectedTab = tab
    }
}

enum RootTab: CaseIterable {
    case reflections
    case wellness
    case achievements
    case settings

    var title: String {
        switch self {
        case .reflections: return "Home"
        case .wellness: return "Wellness"
        case .achievements: return "Stats"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .reflections: return "book.fill"
        case .wellness: return "wind"
        case .achievements: return "rosette"
        case .settings: return "gearshape.fill"
        }
    }
}
