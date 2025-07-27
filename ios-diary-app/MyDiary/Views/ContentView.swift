import SwiftUI

struct ContentView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @State private var isAuthenticated = false
    @State private var needsAuthentication = false
    
    var body: some View {
        Group {
            if needsAuthentication && !isAuthenticated {
                PasswordVerificationView {
                    isAuthenticated = true
                }
            } else {
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
        .onAppear {
            checkAuthentication()
        }
    }
    
    private func checkAuthentication() {
        let hasPassword = UserDefaults.standard.string(forKey: "appPassword") != nil
        needsAuthentication = hasPassword
        isAuthenticated = !hasPassword
    }
}

#Preview {
    ContentView()
        .environmentObject(DiaryStore())
}