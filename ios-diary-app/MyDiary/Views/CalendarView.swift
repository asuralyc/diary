import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Calendar Header
                    CalendarHeader(currentMonth: $currentMonth)
                    
                    // Calendar Grid
                    CalendarGrid(
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        entries: diaryStore.entries
                    )
                    
                    // Month Statistics
                    MonthStatistics(date: currentMonth)
                    
                    // Mood Distribution
                    MoodDistributionChart(date: currentMonth)
                    
                    // Selected Date Entries
                    SelectedDateEntries(selectedDate: selectedDate)
                    
                    Spacer(minLength: 50)
                }
                .padding()
            }
            .navigationTitle("日曆")
        }
    }
}

// MARK: - Calendar Header
struct CalendarHeader: View {
    @Binding var currentMonth: Date
    private let calendar = Calendar.current
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.indigo)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                withAnimation {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.indigo)
            }
        }
        .padding(.horizontal)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: currentMonth)
    }
}

// MARK: - Calendar Grid
struct CalendarGrid: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let entries: [DiaryEntry]
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 8) {
            // Weekday Headers
            HStack {
                ForEach(weekdayHeaders, id: \.self) { weekday in
                    Text(weekday)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasEntry: hasEntry(for: date),
                        mood: moodForDate(date)
                    ) {
                        selectedDate = date
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var weekdayHeaders: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.shortWeekdaySymbols
    }
    
    private var calendarDays: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else {
            return []
        }
        
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        // Find the start of the week for the first day of the month
        let startWeekday = calendar.component(.weekday, from: monthStart)
        let daysFromPreviousMonth = (startWeekday - 1) % 7
        
        guard let calendarStart = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: monthStart) else {
            return []
        }
        
        var days: [Date] = []
        var current = calendarStart
        
        // Generate 6 weeks (42 days) to ensure we always have a complete grid
        for _ in 0..<42 {
            days.append(current)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: current) else {
                break
            }
            current = nextDay
        }
        
        return days
    }
    
    private func hasEntry(for date: Date) -> Bool {
        entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    private func moodForDate(_ date: Date) -> Mood? {
        entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }?.mood
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasEntry: Bool
    let mood: Mood?
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(textColor)
                
                if hasEntry {
                    Circle()
                        .fill(mood?.color ?? .gray)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(width: 40, height: 40)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .indigo
        } else if isCurrentMonth {
            return .primary
        } else {
            return .secondary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .indigo
        } else if isToday {
            return .indigo.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        if isToday && !isSelected {
            return .indigo
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        isToday && !isSelected ? 1 : 0
    }
}

// MARK: - Month Statistics
struct MonthStatistics: View {
    @EnvironmentObject var diaryStore: DiaryStore
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("本月統計")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                StatItem(
                    title: "篇日記",
                    value: "\(monthEntries.count)",
                    color: .blue
                )
                
                StatItem(
                    title: "平均心情",
                    value: averageMood?.emoji ?? "😐",
                    color: .green
                )
                
                StatItem(
                    title: "連續天數",
                    value: "\(monthStreak)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var monthEntries: [DiaryEntry] {
        diaryStore.entriesForMonth(date)
    }
    
    private var averageMood: Mood? {
        diaryStore.averageMood(for: date)
    }
    
    private var monthStreak: Int {
        let sortedDates = monthEntries
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted()
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var maxStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day == 1 {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return maxStreak
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Mood Distribution Chart
struct MoodDistributionChart: View {
    @EnvironmentObject var diaryStore: DiaryStore
    let date: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("心情分佈")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(Mood.allCases.reversed(), id: \.self) { mood in
                    MoodBarView(
                        mood: mood,
                        count: moodDistribution[mood] ?? 0,
                        maxCount: maxMoodCount
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var moodDistribution: [Mood: Int] {
        diaryStore.moodDistribution(for: date)
    }
    
    private var maxMoodCount: Int {
        moodDistribution.values.max() ?? 1
    }
}

struct MoodBarView: View {
    let mood: Mood
    let count: Int
    let maxCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Text(mood.emoji)
                .font(.title3)
                .frame(width: 30)
            
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(mood.color)
                        .frame(width: barWidth(in: geometry.size.width))
                        .animation(.easeInOut(duration: 0.5), value: count)
                    
                    Spacer()
                }
            }
            .frame(height: 20)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(minWidth: 20)
        }
    }
    
    private func barWidth(in totalWidth: CGFloat) -> CGFloat {
        guard maxCount > 0 else { return 0 }
        return totalWidth * CGFloat(count) / CGFloat(maxCount)
    }
}

// MARK: - Selected Date Entries
struct SelectedDateEntries: View {
    @EnvironmentObject var diaryStore: DiaryStore
    let selectedDate: Date
    
    var body: some View {
        let entries = diaryStore.entriesForDate(selectedDate)
        
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text(headerTitle)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                ForEach(entries) { entry in
                    NavigationLink {
                        DiaryDetailView(entry: entry)
                    } label: {
                        DiaryRowView(entry: entry)
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var headerTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        formatter.dateFormat = "M月d日"
        return "\(formatter.string(from: selectedDate)) 的日記"
    }
}

#Preview {
    CalendarView()
        .environmentObject(DiaryStore())
}