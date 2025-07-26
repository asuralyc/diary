import SwiftUI

struct WriteEntryView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedDate = Date()
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood = Mood.happy
    @State private var selectedWeather: Weather? = nil
    @State private var tags = ""
    @State private var showingDatePicker = false
    
    var isEditing: Bool { editingEntry != nil }
    var editingEntry: DiaryEntry?
    
    init(editingEntry: DiaryEntry? = nil) {
        self.editingEntry = editingEntry
        if let entry = editingEntry {
            _selectedDate = State(initialValue: entry.date)
            _title = State(initialValue: entry.title)
            _content = State(initialValue: entry.content)
            _selectedMood = State(initialValue: entry.mood)
            _selectedWeather = State(initialValue: entry.weather)
            _tags = State(initialValue: entry.tags.joined(separator: ", "))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Date Section
                Section {
                    HStack {
                        Text("日期")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button {
                            showingDatePicker = true
                        } label: {
                            HStack {
                                Text(selectedDate, style: .date)
                                    .foregroundColor(.primary)
                                Image(systemName: "calendar")
                                    .foregroundColor(.indigo)
                            }
                        }
                    }
                }
                
                // Mood Section
                Section("今日心情") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            MoodButton(
                                mood: mood,
                                isSelected: selectedMood == mood
                            ) {
                                selectedMood = mood
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Title Section
                Section("標題 (選填)") {
                    TextField("為這篇日記取個標題...", text: $title)
                }
                
                // Content Section
                Section("內容") {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $content)
                            .frame(minHeight: 150)
                        
                        if content.isEmpty {
                            Text("今天發生了什麼事情？你的感想是...")
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                }
                
                // Weather Section
                Section("天氣 (選填)") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(Weather.allCases, id: \.self) { weather in
                            WeatherButton(
                                weather: weather,
                                isSelected: selectedWeather == weather
                            ) {
                                selectedWeather = selectedWeather == weather ? nil : weather
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Tags Section
                Section("標籤 (選填)") {
                    TextField("用逗號分隔標籤，例如：工作,家庭,旅行", text: $tags)
                }
            }
            .navigationTitle(isEditing ? "編輯日記" : "新日記")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveEntry()
                    }
                    .fontWeight(.semibold)
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDate: $selectedDate)
            }
        }
    }
    
    private func saveEntry() {
        let tagArray = tags
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        if let editingEntry = editingEntry {
            // Update existing entry
            let updatedEntry = DiaryEntry(
                id: editingEntry.id,
                date: selectedDate,
                title: title,
                content: content,
                mood: selectedMood,
                weather: selectedWeather,
                tags: tagArray,
                createdAt: editingEntry.createdAt,
                modifiedAt: Date()
            )
            diaryStore.updateEntry(updatedEntry)
        } else {
            // Create new entry
            let newEntry = DiaryEntry(
                date: selectedDate,
                title: title,
                content: content,
                mood: selectedMood,
                weather: selectedWeather,
                tags: tagArray
            )
            diaryStore.addEntry(newEntry)
        }
        
        dismiss()
    }
}

// MARK: - Mood Button
struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(mood.emoji)
                    .font(.title2)
                
                Text(mood.title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? mood.color : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Weather Button
struct WeatherButton: View {
    let weather: Weather
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(weather.emoji)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(isSelected ? Color.indigo : Color(.systemGray6))
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Date Picker View
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "選擇日期",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("選擇日期")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("確定") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    WriteEntryView()
        .environmentObject(DiaryStore())
}