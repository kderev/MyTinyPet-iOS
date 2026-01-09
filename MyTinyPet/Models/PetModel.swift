//
//  PetModel.swift
//  MyTinyPet
//

import Foundation
import SwiftUI

// MARK: - Types d'animaux

enum PetType: String, Codable, CaseIterable, Identifiable {
    case pig = "cochon"
    case dog = "chien"
    case frog = "grenouille"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pig: return "Cochon"
        case .dog: return "Chien"
        case .frog: return "Grenouille"
        }
    }
    
    var emoji: String {
        switch self {
        case .pig: return "🐷"
        case .dog: return "🐶"
        case .frog: return "🐸"
        }
    }
    
    var primaryColor: Color {
        switch self {
        case .pig: return Color(hex: "FFB6C1")
        case .dog: return Color(hex: "DEB887")
        case .frog: return Color(hex: "90EE90")
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .pig: return Color(hex: "FF69B4")
        case .dog: return Color(hex: "8B4513")
        case .frog: return Color(hex: "228B22")
        }
    }
    
    var miniGameName: String {
        switch self {
        case .pig: return "Cherche les truffes"
        case .dog: return "Attrape la balle"
        case .frog: return "Chasse aux moustiques"
        }
    }
}

// MARK: - Stades d'évolution

enum EvolutionStage: String, Codable, CaseIterable {
    case baby = "bébé"
    case child = "enfant"
    case adult = "adulte"
    case senior = "senior"
    
    var requiredLevel: Int {
        switch self {
        case .baby: return 1
        case .child: return 5
        case .adult: return 15
        case .senior: return 30
        }
    }
    
    var emoji: String {
        switch self {
        case .baby: return "🐣"
        case .child: return "🌱"
        case .adult: return "⭐"
        case .senior: return "👑"
        }
    }
    
    var sizeMultiplier: CGFloat {
        switch self {
        case .baby: return 0.7
        case .child: return 0.85
        case .adult: return 1.0
        case .senior: return 1.1
        }
    }
    
    var decayMultiplier: Double {
        switch self {
        case .baby: return 1.3
        case .child: return 1.1
        case .adult: return 1.0
        case .senior: return 0.8
        }
    }
    
    var nextStage: EvolutionStage? {
        switch self {
        case .baby: return .child
        case .child: return .adult
        case .adult: return .senior
        case .senior: return nil
        }
    }
}

// MARK: - États émotionnels

enum PetMood: String, Codable {
    case happy = "content"
    case sad = "triste"
    case tired = "fatigué"
    case hungry = "affamé"
    case thirsty = "assoiffé"
    case loving = "aimant"
    case neutral = "neutre"
    case needsWalk = "veut sortir"
    case playful = "joueur"
    
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .tired: return "😴"
        case .hungry: return "😋"
        case .thirsty: return "😰"
        case .loving: return "🥰"
        case .neutral: return "😐"
        case .needsWalk: return "🚶"
        case .playful: return "🤪"
        }
    }
    
    var statusMessage: String {
        switch self {
        case .happy: return "Je suis tellement heureux !"
        case .sad: return "Je me sens un peu triste..."
        case .tired: return "Je suis fatigué... Zzz"
        case .hungry: return "J'ai faim ! 🍎"
        case .thirsty: return "J'ai soif ! 💧"
        case .loving: return "Je t'aime ! ❤️"
        case .neutral: return "Tout va bien."
        case .needsWalk: return "J'ai besoin de sortir ! 🌳"
        case .playful: return "On joue ensemble ? 🎮"
        }
    }
}

// MARK: - Actions

enum PetAction: String, CaseIterable {
    case feed = "nourrir"
    case drink = "abreuver"
    case pet = "caresser"
    case walk = "promener"
    case play = "jouer"
    
    var icon: String {
        switch self {
        case .feed: return "🍎"
        case .drink: return "💧"
        case .pet: return "❤️"
        case .walk: return "🌳"
        case .play: return "🎮"
        }
    }
    
    var displayName: String {
        switch self {
        case .feed: return "Nourrir"
        case .drink: return "Boire"
        case .pet: return "Câliner"
        case .walk: return "Promener"
        case .play: return "Jouer"
        }
    }
    
    var color: Color {
        switch self {
        case .feed: return .orange
        case .drink: return .blue
        case .pet: return .pink
        case .walk: return .green
        case .play: return .purple
        }
    }
    
    var xpReward: Int {
        switch self {
        case .feed: return 5
        case .drink: return 5
        case .pet: return 8
        case .walk: return 15
        case .play: return 20
        }
    }
}

// MARK: - Modèle principal

struct Pet: Codable, Identifiable {
    var id: UUID
    var name: String
    var type: PetType
    var hunger: Double
    var thirst: Double
    var affection: Double
    var bladder: Double
    var creationDate: Date
    var lastInteractionDate: Date
    
    // Évolution
    var xp: Int
    var level: Int
    var evolutionStage: EvolutionStage
    
    // Mini-jeux
    var lastMiniGameDate: Date?
    var miniGamesPlayedToday: Int
    var totalMiniGamesPlayed: Int
    var highScore: Int
    
    // Promenades
    var totalWalks: Int
    var lastWalkDate: Date?
    
    init(name: String = "Mon petit", type: PetType) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.hunger = 80.0
        self.thirst = 80.0
        self.affection = 80.0
        self.bladder = 80.0
        self.creationDate = Date()
        self.lastInteractionDate = Date()
        self.xp = 0
        self.level = 1
        self.evolutionStage = .baby
        self.lastMiniGameDate = nil
        self.miniGamesPlayedToday = 0
        self.totalMiniGamesPlayed = 0
        self.highScore = 0
        self.totalWalks = 0
        self.lastWalkDate = nil
    }
    
    var xpForNextLevel: Int {
        return level * 50 + 50
    }
    
    var levelProgress: Double {
        return Double(xp) / Double(xpForNextLevel)
    }
    
    var canPlayMiniGame: Bool {
        guard let lastGame = lastMiniGameDate else { return true }
        if !Calendar.current.isDateInToday(lastGame) { return true }
        return miniGamesPlayedToday < 3
    }
    
    var currentMood: PetMood {
        if bladder < 20 { return .needsWalk }
        if hunger < 20 { return .hungry }
        if thirst < 20 { return .thirsty }
        if affection < 20 { return .sad }
        
        let avg = (hunger + thirst + affection + bladder) / 4
        if avg < 30 { return .tired }
        if avg < 50 { return .neutral }
        if canPlayMiniGame && affection > 60 { return .playful }
        if affection > 80 { return .loving }
        return .happy
    }
    
    var happinessScore: Double {
        return (hunger + thirst + affection + bladder) / 4
    }
    
    var daysSinceCreation: Int {
        let days = Calendar.current.dateComponents([.day], from: creationDate, to: Date()).day ?? 0
        return max(1, days + 1)
    }
    
    var canEvolve: Bool {
        guard let next = evolutionStage.nextStage else { return false }
        return level >= next.requiredLevel
    }
}

// MARK: - Extension Color

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
