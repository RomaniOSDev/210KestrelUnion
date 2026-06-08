import Foundation
import Combine

final class EmotionalProgressViewModel: ObservableObject {
    @Published var selectedWeeklyIndex: Int?
    @Published var selectedHeatmapCell: (row: Int, col: Int)?
    @Published var weekShift: Int = 0
    @Published var monthShift: Int = 0

    func shiftWeek(left: Bool) {
        weekShift += left ? -1 : 1
    }

    func shiftMonth(left: Bool) {
        monthShift += left ? -1 : 1
    }
}
