import Foundation
import SwiftUI

// MARK: - Diary Store (Data Manager)
@MainActor
class DiaryStore: ObservableObject {
    @Published var entries: [DiaryEntry] = []
    
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private var dataURL: URL {
        documentsDirectory.appendingPathComponent("diary_entries.json")
    }
    
    init() {
        loadEntries()
    }
    
    // MARK: - Data Persistence
    func saveEntries() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: dataURL)
        } catch {
            print("Failed to save entries: \(error)")
        }
    }
    
    func loadEntries() {
        do {
            let data = try Data(contentsOf: dataURL)
            entries = try JSONDecoder().decode([DiaryEntry].self, from: data)
        } catch {
            // If file doesn't exist or there's an error, load sample data
            entries = DiaryEntry.sampleData
            saveEntries()
        }
    }
    
    // MARK: - CRUD Operations
    func addEntry(_ entry: DiaryEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func updateEntry(_ entry: DiaryEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            var updatedEntry = entry
            updatedEntry.modifiedAt = Date()
            entries[index] = updatedEntry
            saveEntries()
        }
    }
    
    func deleteEntry(_ entry: DiaryEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    func deleteEntry(at indexSet: IndexSet) {
        entries.remove(atOffsets: indexSet)
        saveEntries()
    }
    
    // MARK: - Computed Properties
    var sortedEntries: [DiaryEntry] {
        entries.sorted { $0.createdAt > $1.createdAt }
    }
    
    var recentEntries: [DiaryEntry] {
        Array(sortedEntries.prefix(3))
    }
    
    var totalEntries: Int {
        entries.count
    }
    
    var thisMonthEntries: Int {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        
        return entries.filter { entry in
            let entryMonth = Calendar.current.component(.month, from: entry.date)
            let entryYear = Calendar.current.component(.year, from: entry.date)
            return entryMonth == currentMonth && entryYear == currentYear
        }.count
    }
    
    var streak: Int {
        let sortedDates = entries
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var currentStreak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for date in sortedDates {
            if date == currentDate {
                currentStreak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            } else if date < currentDate {
                break
            }
        }
        
        return currentStreak
    }
    
    func todayEntry() -> DiaryEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.first { entry in
            Calendar.current.startOfDay(for: entry.date) == today
        }
    }
    
    func entriesForDate(_ date: Date) -> [DiaryEntry] {
        let targetDate = Calendar.current.startOfDay(for: date)
        return entries.filter { entry in
            Calendar.current.startOfDay(for: entry.date) == targetDate
        }
    }
    
    func entriesForMonth(_ date: Date) -> [DiaryEntry] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        return entries.filter { entry in
            let entryMonth = calendar.component(.month, from: entry.date)
            let entryYear = calendar.component(.year, from: entry.date)
            return entryMonth == month && entryYear == year
        }
    }
    
    func moodDistribution(for date: Date) -> [Mood: Int] {
        let monthEntries = entriesForMonth(date)
        var distribution: [Mood: Int] = [:]
        
        for mood in Mood.allCases {
            distribution[mood] = 0
        }
        
        for entry in monthEntries {
            distribution[entry.mood, default: 0] += 1
        }
        
        return distribution
    }
    
    func averageMood(for date: Date) -> Mood? {
        let monthEntries = entriesForMonth(date)
        guard !monthEntries.isEmpty else { return nil }
        
        let distribution = moodDistribution(for: date)
        return distribution.max(by: { $0.value < $1.value })?.key
    }
}