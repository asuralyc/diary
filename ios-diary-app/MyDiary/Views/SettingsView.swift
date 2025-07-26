import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingClearDataAlert = false
    @State private var nickname = "我的日記"
    @State private var reminderEnabled = true
    @State private var reminderTime = Date()
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section("個人資料") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.indigo)
                        
                        VStack(alignment: .leading) {
                            Text("暱稱")
                                .font(.headline)
                            TextField("輸入暱稱", text: $nickname)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Diary Settings
                Section("日記設定") {
                    HStack {
                        Image(systemName: "bell")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading) {
                            Text("每日提醒")
                            Text("提醒你寫日記")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $reminderEnabled)
                    }
                    .padding(.vertical, 4)
                    
                    if reminderEnabled {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("提醒時間")
                                Text(reminderTime, style: .time)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Data Management
                Section("資料管理") {
                    Button {
                        showingExportSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading) {
                                Text("匯出資料")
                                    .foregroundColor(.primary)
                                Text("備份所有日記")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button {
                        showingImportSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text("匯入資料")
                                    .foregroundColor(.primary)
                                Text("從備份檔案還原")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    Button {
                        showingClearDataAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading) {
                                Text("清除所有資料")
                                    .foregroundColor(.red)
                                Text("永久刪除所有日記")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Statistics
                Section("統計資訊") {
                    StatisticRow(
                        icon: "book.closed",
                        title: "總日記數",
                        value: "\(diaryStore.totalEntries)",
                        color: .indigo
                    )
                    
                    StatisticRow(
                        icon: "calendar",
                        title: "本月日記",
                        value: "\(diaryStore.thisMonthEntries)",
                        color: .green
                    )
                    
                    StatisticRow(
                        icon: "flame",
                        title: "連續天數",
                        value: "\(diaryStore.streak)",
                        color: .orange
                    )
                    
                    if let firstEntry = diaryStore.sortedEntries.last {
                        StatisticRow(
                            icon: "calendar.badge.plus",
                            title: "開始日期",
                            value: firstEntry.date.formatted(date: .abbreviated, time: .omitted),
                            color: .purple
                        )
                    }
                }
                
                // About
                Section("關於") {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading) {
                            Text("版本")
                            Text("1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    
                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Image(systemName: "heart")
                                .foregroundColor(.pink)
                            
                            VStack(alignment: .leading) {
                                Text("意見回饋")
                                    .foregroundColor(.primary)
                                Text("告訴我們你的想法")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("設定")
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView()
        }
        .fileImporter(
            isPresented: $showingImportSheet,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .alert("確認清除所有資料", isPresented: $showingClearDataAlert) {
            Button("取消", role: .cancel) {}
            Button("清除", role: .destructive) {
                clearAllData()
            }
        } message: {
            Text("這將永久刪除所有日記和設定，確定要繼續嗎？")
        }
    }
    
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importData(from: url)
        case .failure(let error):
            print("Import failed: \(error)")
        }
    }
    
    private func importData(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let importedEntries = try JSONDecoder().decode([DiaryEntry].self, from: data)
            
            // Replace all entries with imported data
            diaryStore.entries = importedEntries
            diaryStore.saveEntries()
        } catch {
            print("Failed to import data: \(error)")
        }
    }
    
    private func clearAllData() {
        diaryStore.entries.removeAll()
        diaryStore.saveEntries()
    }
}

// MARK: - Statistic Row
struct StatisticRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            VStack(alignment: .leading) {
                Text(title)
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Export View
struct ExportView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @Environment(\.dismiss) var dismiss
    @State private var showingShareSheet = false
    @State private var exportData: Data?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.indigo)
                
                VStack(spacing: 8) {
                    Text("匯出日記資料")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("將會匯出所有 \(diaryStore.totalEntries) 篇日記")
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 16) {
                    Button {
                        exportToJSON()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text")
                            Text("匯出為 JSON 檔案")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.indigo)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    Button {
                        exportToText()
                    } label: {
                        HStack {
                            Image(systemName: "doc.plaintext")
                            Text("匯出為純文字")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("匯出資料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
                                .sheet(isPresented: $showingShareSheet) {
                            if let exportData = exportData {
                                DataShareSheet(data: exportData)
                            }
                        }
    }
    
    private func exportToJSON() {
        do {
            let data = try JSONEncoder().encode(diaryStore.entries)
            exportData = data
            showingShareSheet = true
        } catch {
            print("Export failed: \(error)")
        }
    }
    
    private func exportToText() {
        let textContent = generateTextExport()
        exportData = textContent.data(using: .utf8)
        showingShareSheet = true
    }
    
    private func generateTextExport() -> String {
        var content = "我的日記匯出\n"
        content += "匯出時間：\(Date().formatted())\n"
        content += "總日記數：\(diaryStore.entries.count)\n\n"
        content += String(repeating: "=", count: 50) + "\n\n"
        
        for entry in diaryStore.sortedEntries {
            content += "日期：\(entry.date.formatted(date: .complete, time: .omitted))\n"
            content += "心情：\(entry.mood.emoji) \(entry.mood.title)\n"
            
            if let weather = entry.weather {
                content += "天氣：\(weather.emoji) \(weather.title)\n"
            }
            
            if !entry.title.isEmpty {
                content += "標題：\(entry.title)\n"
            }
            
            content += "\n\(entry.content)\n"
            
            if !entry.tags.isEmpty {
                content += "\n標籤：\(entry.tags.joined(separator: "、"))\n"
            }
            
            content += "\n" + String(repeating: "-", count: 30) + "\n\n"
        }
        
        return content
    }
}

struct DataShareSheet: UIViewControllerRepresentable {
    let data: Data
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityController = UIActivityViewController(
            activityItems: [data],
            applicationActivities: nil
        )
        return activityController
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView()
        .environmentObject(DiaryStore())
}