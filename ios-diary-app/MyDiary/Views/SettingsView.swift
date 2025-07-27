import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var showingExportSheet = false
    @State private var showingImportSheet = false
    @State private var showingClearDataAlert = false
    @State private var nickname = "我的日記"
    @State private var reminderEnabled = true
    @State private var reminderTime = Date()
    @State private var privacyEnabled = false
    @State private var showingPasswordAlert = false
    @State private var showingChangePasswordAlert = false
    @State private var passwordText = ""
    @State private var confirmPasswordText = ""
    @State private var currentPasswordText = ""
    @State private var showingNicknameAlert = false
    @State private var tempNickname = ""
    @State private var showingNotificationAlert = false
    
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
                            Text(nickname)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("編輯") {
                            tempNickname = nickname
                            showingNicknameAlert = true
                        }
                        .foregroundColor(.indigo)
                    }
                    .padding(.vertical, 4)
                }
                
                // Diary Settings
                Section("日記設定") {
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading) {
                            Text("隱私保護")
                            Text("設定密碼保護")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $privacyEnabled)
                    }
                    .padding(.vertical, 4)
                    
                    if UserDefaults.standard.string(forKey: "appPassword") != nil {
                        Button {
                            showingChangePasswordAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "key")
                                    .foregroundColor(.orange)
                                
                                VStack(alignment: .leading) {
                                    Text("更改密碼")
                                        .foregroundColor(.primary)
                                    Text("修改現有密碼")
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
        .alert("編輯暱稱", isPresented: $showingNicknameAlert) {
            TextField("暱稱", text: $tempNickname)
            Button("取消", role: .cancel) {}
            Button("儲存") {
                saveNickname()
            }
        } message: {
            Text("請輸入新的暱稱")
        }
        .alert("設定密碼", isPresented: $showingPasswordAlert) {
            SecureField("密碼", text: $passwordText)
            SecureField("確認密碼", text: $confirmPasswordText)
            Button("取消", role: .cancel) {
                privacyEnabled = false
                passwordText = ""
                confirmPasswordText = ""
            }
            Button("確認") {
                setPassword()
            }
        } message: {
            Text("請設定密碼以保護您的日記")
        }
        .alert("更改密碼", isPresented: $showingChangePasswordAlert) {
            SecureField("目前密碼", text: $currentPasswordText)
            SecureField("新密碼", text: $passwordText)
            SecureField("確認新密碼", text: $confirmPasswordText)
            Button("取消", role: .cancel) {
                clearPasswordFields()
            }
            Button("更改") {
                changePassword()
            }
        } message: {
            Text("請輸入目前密碼和新密碼")
        }
        .onChange(of: privacyEnabled) { _, newValue in
            if newValue {
                if UserDefaults.standard.string(forKey: "appPassword") == nil {
                    showingPasswordAlert = true
                }
            }
        }
        .onAppear {
            loadSettings()
        }
        .onChange(of: reminderEnabled) { _, newValue in
            if newValue {
                checkNotificationPermission()
            } else {
                UserDefaults.standard.set(newValue, forKey: "reminderEnabled")
                NotificationManager.shared.cancelDailyReminder()
            }
        }
        .onChange(of: reminderTime) { _, newValue in
            UserDefaults.standard.set(newValue, forKey: "reminderTime")
            if reminderEnabled {
                NotificationManager.shared.scheduleDaily(at: newValue, enabled: true)
            }
        }
        .alert("需要通知權限", isPresented: $showingNotificationAlert) {
            Button("設定") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("取消", role: .cancel) {
                reminderEnabled = false
            }
        } message: {
            Text("請到「設定」>「通知」中允許此App發送通知，才能使用每日提醒功能")
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
    
    private func loadSettings() {
        nickname = UserDefaults.standard.string(forKey: "userNickname") ?? "我的日記"
        privacyEnabled = UserDefaults.standard.string(forKey: "appPassword") != nil
        reminderEnabled = UserDefaults.standard.bool(forKey: "reminderEnabled")
        if let reminderHour = UserDefaults.standard.object(forKey: "reminderTime") as? Date {
            reminderTime = reminderHour
        }
        
        // 如果提醒已啟用，重新設定通知
        if reminderEnabled {
            NotificationManager.shared.scheduleDaily(at: reminderTime, enabled: true)
        }
    }
    
    private func saveNickname() {
        guard !tempNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        nickname = tempNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(nickname, forKey: "userNickname")
        tempNickname = ""
    }
    
    private func setPassword() {
        guard !passwordText.isEmpty, passwordText == confirmPasswordText else {
            privacyEnabled = false
            passwordText = ""
            confirmPasswordText = ""
            return
        }
        
        UserDefaults.standard.set(passwordText, forKey: "appPassword")
        clearPasswordFields()
    }
    
    private func changePassword() {
        let savedPassword = UserDefaults.standard.string(forKey: "appPassword")
        
        guard currentPasswordText == savedPassword else {
            clearPasswordFields()
            return
        }
        
        guard !passwordText.isEmpty, passwordText == confirmPasswordText else {
            clearPasswordFields()
            return
        }
        
        UserDefaults.standard.set(passwordText, forKey: "appPassword")
        clearPasswordFields()
    }
    
    private func clearPasswordFields() {
        passwordText = ""
        confirmPasswordText = ""
        currentPasswordText = ""
    }
    
    private func checkNotificationPermission() {
        NotificationManager.shared.checkNotificationStatus { status in
            switch status {
            case .notDetermined:
                NotificationManager.shared.requestPermission()
                UserDefaults.standard.set(true, forKey: "reminderEnabled")
                NotificationManager.shared.scheduleDaily(at: reminderTime, enabled: true)
            case .authorized:
                UserDefaults.standard.set(true, forKey: "reminderEnabled")
                NotificationManager.shared.scheduleDaily(at: reminderTime, enabled: true)
            case .denied, .provisional:
                showingNotificationAlert = true
            @unknown default:
                showingNotificationAlert = true
            }
        }
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
        let userNickname = UserDefaults.standard.string(forKey: "userNickname") ?? "我的日記"
        var content = "\(userNickname)匯出\n"
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