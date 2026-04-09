import Foundation

class ScanLimiter: ObservableObject {
    private let dailyLimit = 10
    private let defaults = UserDefaults.standard
    private let scanCountKey = "scanCount"
    private let lastResetKey = "lastResetDate"

    @Published var scansUsed: Int = 0

    var scansRemaining: Int { max(0, dailyLimit - scansUsed) }
    var canScan: Bool { scansRemaining > 0 }

    init() {
        resetIfNewDay()
        scansUsed = defaults.integer(forKey: scanCountKey)
    }

    func consumeScan() {
        resetIfNewDay()
        scansUsed += 1
        defaults.set(scansUsed, forKey: scanCountKey)
    }

    func resetCounter() {
        scansUsed = 0
        defaults.set(0, forKey: scanCountKey)
        defaults.set(Calendar.current.startOfDay(for: Date()), forKey: lastResetKey)
    }

    private func resetIfNewDay() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastReset = defaults.object(forKey: lastResetKey) as? Date ?? .distantPast

        if today > lastReset {
            defaults.set(0, forKey: scanCountKey)
            defaults.set(today, forKey: lastResetKey)
            scansUsed = 0
        }
    }
}
