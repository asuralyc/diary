import Foundation
import SwiftUI

// MARK: - Diary Entry Model
struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    var date: Date
    var title: String
    var content: String
    var mood: Mood
    var weather: Weather?
    var tags: [String]
    var createdAt: Date
    var modifiedAt: Date
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        title: String = "",
        content: String,
        mood: Mood = .happy,
        weather: Weather? = nil,
        tags: [String] = [],
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.content = content
        self.mood = mood
        self.weather = weather
        self.tags = tags
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}

// MARK: - Mood Enum
enum Mood: String, CaseIterable, Codable {
    case verySad = "very-sad"
    case sad = "sad"
    case neutral = "neutral"
    case happy = "happy"
    case veryHappy = "very-happy"
    case love = "love"
    
    var emoji: String {
        switch self {
        case .verySad: return "😢"
        case .sad: return "😔"
        case .neutral: return "😐"
        case .happy: return "😊"
        case .veryHappy: return "😆"
        case .love: return "🥰"
        }
    }
    
    var title: String {
        switch self {
        case .verySad: return "很難過"
        case .sad: return "難過"
        case .neutral: return "普通"
        case .happy: return "開心"
        case .veryHappy: return "很開心"
        case .love: return "超開心"
        }
    }
    
    var color: Color {
        switch self {
        case .verySad: return .red
        case .sad: return .orange
        case .neutral: return .gray
        case .happy: return .green
        case .veryHappy: return .blue
        case .love: return .pink
        }
    }
}

// MARK: - Weather Enum
enum Weather: String, CaseIterable, Codable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rainy = "rainy"
    case snowy = "snowy"
    case stormy = "stormy"
    
    var emoji: String {
        switch self {
        case .sunny: return "☀️"
        case .cloudy: return "☁️"
        case .rainy: return "🌧️"
        case .snowy: return "❄️"
        case .stormy: return "⛈️"
        }
    }
    
    var title: String {
        switch self {
        case .sunny: return "晴天"
        case .cloudy: return "多雲"
        case .rainy: return "雨天"
        case .snowy: return "雪天"
        case .stormy: return "暴風雨"
        }
    }
}

// MARK: - Sample Data
extension DiaryEntry {
    static var sampleData: [DiaryEntry] {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
        let dayBefore = Calendar.current.date(byAdding: .day, value: -2, to: today) ?? today
        
        return [
            DiaryEntry(
                date: today,
                title: "",
                content: "今天去了海邊，看到了美麗的夕陽。心情特別放鬆，感覺所有的煩惱都被海浪帶走了。海風輕拂著臉龐，溫暖但不燥熱。我坐在沙灘上，看著太陽慢慢沉入海平線，天空被染成了橘紅色。這種時刻讓我想起了小時候和家人一起度假的美好時光。",
                mood: .happy,
                weather: .sunny,
                tags: ["海邊", "夕陽", "放鬆"],
                createdAt: today,
                modifiedAt: today
            ),
            DiaryEntry(
                date: yesterday,
                title: "工作挑戰",
                content: "工作上遇到了一些挑戰，但是透過團隊合作順利解決了。學到了很多新的東西，特別是關於溝通的重要性。雖然過程有些辛苦，但最終的成果讓我覺得很有成就感。",
                mood: .neutral,
                weather: .cloudy,
                tags: ["工作", "學習", "團隊"],
                createdAt: yesterday,
                modifiedAt: yesterday
            ),
            DiaryEntry(
                date: dayBefore,
                title: "電影之夜",
                content: "和朋友一起看電影，度過了愉快的晚上。友誼真的是人生中最珍貴的財富。我們看了一部很有趣的喜劇片，笑得肚子都痛了。之後還一起吃了宵夜，聊了很多以前的回憶。",
                mood: .veryHappy,
                weather: .cloudy,
                tags: ["朋友", "電影", "友誼"],
                createdAt: dayBefore,
                modifiedAt: dayBefore
            )
        ]
    }
}