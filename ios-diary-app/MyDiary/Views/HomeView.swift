import SwiftUI

struct HomeView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var showingWriteView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("我的日記")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(dateString)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // User Avatar
                        Circle()
                            .fill(Color.indigo.gradient)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Text("我")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                    }
                    .padding(.horizontal)
                    
                    // Today's Mood
                    TodayMoodCard()
                    
                    // Statistics
                    StatisticsRow()
                    
                    // Recent Entries
                    RecentEntriesSection()
                    
                    Spacer(minLength: 100)
                }
            }
            .refreshable {
                // Refresh data if needed
            }
            .sheet(isPresented: $showingWriteView) {
                WriteEntryView()
            }
            .overlay(alignment: .bottomTrailing) {
                // Floating Action Button
                Button {
                    showingWriteView = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(Color.indigo)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: Date())
    }
}

// MARK: - Today's Mood Card
struct TodayMoodCard: View {
    @EnvironmentObject var diaryStore: DiaryStore
    
    var body: some View {
        VStack(spacing: 12) {
            Text("今日心情")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let todayEntry = diaryStore.todayEntry() {
                VStack(spacing: 8) {
                    Text(todayEntry.mood.emoji)
                        .font(.system(size: 50))
                    
                    Text(todayEntry.mood.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(todayEntry.mood.color)
                }
            } else {
                VStack(spacing: 8) {
                    Text("😐")
                        .font(.system(size: 50))
                    
                    Text("還沒記錄")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Statistics Row
struct StatisticsRow: View {
    @EnvironmentObject var diaryStore: DiaryStore
    
    var body: some View {
        HStack(spacing: 15) {
            StatCard(
                title: "總日記數",
                value: "\(diaryStore.totalEntries)",
                color: .blue
            )
            
            StatCard(
                title: "本月日記",
                value: "\(diaryStore.thisMonthEntries)",
                color: .green
            )
            
            StatCard(
                title: "連續天數",
                value: "\(diaryStore.streak)",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Recent Entries Section
struct RecentEntriesSection: View {
    @EnvironmentObject var diaryStore: DiaryStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("最近的日記")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                NavigationLink("查看全部") {
                    DiaryListView()
                }
                .font(.subheadline)
                .foregroundColor(.indigo)
            }
            .padding(.horizontal)
            
            if diaryStore.recentEntries.isEmpty {
                EmptyStateView()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(diaryStore.recentEntries) { entry in
                        NavigationLink {
                            DiaryDetailView(entry: entry)
                        } label: {
                            DiaryRowView(entry: entry)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("還沒有日記")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("開始寫下你的第一篇日記吧！")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .environmentObject(DiaryStore())
}