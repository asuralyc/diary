import SwiftUI

struct ContentView: View {
    @StateObject private var diaryStore = DiaryStore()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首頁")
                }
            
            DiaryListView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("日記")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("日曆")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
        }
        .environmentObject(diaryStore)
        .accentColor(.indigo)
    }
}

#Preview {
    ContentView()
}