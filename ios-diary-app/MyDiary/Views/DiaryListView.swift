import SwiftUI

struct DiaryListView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var searchText = ""
    @State private var selectedFilter: FilterOption = .all
    @State private var selectedMoodFilter: Mood? = nil
    @State private var showingWriteView = false
    
    enum FilterOption: String, CaseIterable {
        case all = "全部"
        case thisMonth = "本月"
        case thisYear = "今年"
    }
    
    var filteredEntries: [DiaryEntry] {
        var entries = diaryStore.sortedEntries
        
        // Apply time filter
        switch selectedFilter {
        case .all:
            break
        case .thisMonth:
            let currentMonth = Calendar.current.component(.month, from: Date())
            let currentYear = Calendar.current.component(.year, from: Date())
            entries = entries.filter { entry in
                let entryMonth = Calendar.current.component(.month, from: entry.date)
                let entryYear = Calendar.current.component(.year, from: entry.date)
                return entryMonth == currentMonth && entryYear == currentYear
            }
        case .thisYear:
            let currentYear = Calendar.current.component(.year, from: Date())
            entries = entries.filter { entry in
                Calendar.current.component(.year, from: entry.date) == currentYear
            }
        }
        
        // Apply mood filter
        if let selectedMoodFilter = selectedMoodFilter {
            entries = entries.filter { $0.mood == selectedMoodFilter }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            entries = entries.filter { entry in
                entry.content.localizedCaseInsensitiveContains(searchText) ||
                entry.title.localizedCaseInsensitiveContains(searchText) ||
                entry.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return entries
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter Bar
                FilterBar(
                    selectedFilter: $selectedFilter,
                    selectedMoodFilter: $selectedMoodFilter
                )
                
                // Content
                if filteredEntries.isEmpty {
                    if diaryStore.entries.isEmpty {
                        EmptyStateView()
                    } else {
                        NoResultsView()
                    }
                } else {
                    List {
                        ForEach(filteredEntries) { entry in
                            NavigationLink {
                                DiaryDetailView(entry: entry)
                            } label: {
                                DiaryRowView(entry: entry)
                            }
                        }
                        .onDelete(perform: deleteEntries)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("我的日記")
            .searchable(text: $searchText, prompt: "搜尋日記內容、標題或標籤...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingWriteView = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingWriteView) {
                WriteEntryView()
            }
        }
    }
    
    private func deleteEntries(at indexSet: IndexSet) {
        for index in indexSet {
            let entry = filteredEntries[index]
            diaryStore.deleteEntry(entry)
        }
    }
}

// MARK: - Filter Bar
struct FilterBar: View {
    @Binding var selectedFilter: DiaryListView.FilterOption
    @Binding var selectedMoodFilter: Mood?
    
    var body: some View {
        VStack(spacing: 12) {
            // Time Filter
            HStack {
                ForEach(DiaryListView.FilterOption.allCases, id: \.self) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? Color.indigo : Color(.systemGray6))
                            .foregroundColor(selectedFilter == filter ? .white : .primary)
                            .cornerRadius(20)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            
            // Mood Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button {
                        selectedMoodFilter = nil
                    } label: {
                        Text("所有心情")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedMoodFilter == nil ? Color.indigo : Color(.systemGray6))
                            .foregroundColor(selectedMoodFilter == nil ? .white : .primary)
                            .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    ForEach(Mood.allCases, id: \.self) { mood in
                        Button {
                            selectedMoodFilter = selectedMoodFilter == mood ? nil : mood
                        } label: {
                            HStack(spacing: 4) {
                                Text(mood.emoji)
                                Text(mood.title)
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedMoodFilter == mood ? mood.color : Color(.systemGray6))
                            .foregroundColor(selectedMoodFilter == mood ? .white : .primary)
                            .cornerRadius(16)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

// MARK: - Diary Row View
struct DiaryRowView: View {
    let entry: DiaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text(entry.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(entry.mood.emoji)
                    
                    if let weather = entry.weather {
                        Text(weather.emoji)
                    }
                }
            }
            
            // Title
            if !entry.title.isEmpty {
                Text(entry.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }
            
            // Content Preview
            Text(entry.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            // Tags
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                    }
                    .padding(.leading, 0)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - No Results View
struct NoResultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("沒有找到相關日記")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("試試其他關鍵字或篩選條件")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DiaryListView()
        .environmentObject(DiaryStore())
}