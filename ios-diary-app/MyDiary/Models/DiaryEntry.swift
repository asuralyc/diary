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

