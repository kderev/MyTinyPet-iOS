//
//  PetModel.swift
//  MyTinyPet
//
//  Modèle de données pour représenter l'animal virtuel
//

import Foundation
import SwiftUI

// MARK: - Types d'animaux disponibles

/// Les trois types d'animaux que le joueur peut choisir
enum PetType: String, Codable, CaseIterable, Identifiable {
    case pig = "cochon"
    case dog = "chien"
    case frog = "grenouille"
    
    var id: String { rawValue }
    
    /// Nom d'affichage localisé
    var displayName: String {
        switch self {
        case .pig: return "Cochon"
        case .dog: return "Chien"
        case .frog: return "Grenouille"
        }
    }
    
    /// Emoji représentant l'animal
    var emoji: String {
        switch self {
        case .pig: return "🐷"
        case .dog: return "🐶"
        case .frog: return "🐸"
        }
    }
    
    /// Couleur principale de l'animal
    var primaryColor: Color {
        switch self {
        case .pig: return Color(hex: "FFB6C1")   // Rose clair
        case .dog: return Color(hex: "DEB887")   // Brun clair
        case .frog: return Color(hex: "90EE90")  // Vert clair
        }
    }
    
    /// Couleur secondaire de l'animal
    var secondaryColor: Color {
        switch self {
        case .pig: return Color(hex: "FF69B4")   // Rose vif
        case .dog: return Color(hex: "8B4513")   // Brun foncé
        case .frog: return Color(hex: "228B22")  // Vert forêt
        }
    }
}

// MARK: - États émotionnels

/// Les différentes expressions/humeurs de l'animal
enum PetMood: String, Codable {
    case happy = "content"
    case sad = "triste"
    case tired = "fatigué"
    case hungry = "affamé"
    case thirsty = "assoiffé"
    case loving = "aimant"
    case neutral = "neutre"
    
    /// Emoji représentant l'humeur
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .tired: return "😴"
        case .hungry: return "😋"
        case .thirsty: return "😰"
        case .loving: return "🥰"
        case .neutral: return "😐"
        }
    }
    
    /// Message d'état de l'animal
    var statusMessage: String {
        switch self {
        case .happy: return "Je suis tellement heureux !"
        case .sad: return "Je me sens un peu triste..."
        case .tired: return "Je suis fatigué... Zzz"
        case .hungry: return "J'ai faim ! 🍎"
        case .thirsty: return "J'ai soif ! 💧"
        case .loving: return "Je t'aime ! ❤️"
        case .neutral: return "Tout va bien."
        }
    }
}

// MARK: - Actions possibles

/// Les actions que le joueur peut effectuer
enum PetAction: String, CaseIterable {
    case feed = "nourrir"
    case drink = "abreuver"
    case pet = "caresser"
    
    /// Icône de l'action
    var icon: String {
        switch self {
        case .feed: return "🍎"
        case .drink: return "💧"
        case .pet: return "❤️"
        }
    }
    
    /// Nom d'affichage
    var displayName: String {
        switch self {
        case .feed: return "Nourrir"
        case .drink: return "Donner à boire"
        case .pet: return "Caresser"
        }
    }
    
    /// Couleur du bouton d'action
    var color: Color {
        switch self {
        case .feed: return .orange
        case .drink: return .blue
        case .pet: return .pink
        }
    }
}

// MARK: - Modèle principal de l'animal

/// Structure représentant l'état complet de l'animal
struct Pet: Codable, Identifiable {
    var id: UUID
    var name: String
    var type: PetType
    var hunger: Double      // 0-100, 100 = rassasié
    var thirst: Double      // 0-100, 100 = hydraté
    var affection: Double   // 0-100, 100 = très aimé
    var creationDate: Date
    var lastInteractionDate: Date
    
    /// Initialisation d'un nouvel animal
    init(name: String = "Mon petit", type: PetType) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.hunger = 80.0
        self.thirst = 80.0
        self.affection = 80.0
        self.creationDate = Date()
        self.lastInteractionDate = Date()
    }
    
    /// Calcule l'humeur actuelle basée sur les statistiques
    var currentMood: PetMood {
        let averageStats = (hunger + thirst + affection) / 3
        
        // Priorité aux besoins critiques
        if hunger < 20 { return .hungry }
        if thirst < 20 { return .thirsty }
        if affection < 20 { return .sad }
        
        // États intermédiaires
        if averageStats < 30 { return .tired }
        if averageStats < 50 { return .neutral }
        if affection > 80 { return .loving }
        
        return .happy
    }
    
    /// Score de bonheur global (0-100)
    var happinessScore: Double {
        return (hunger + thirst + affection) / 3
    }
    
    /// Nombre de jours depuis la création
    var daysSinceCreation: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: creationDate, to: Date())
        return max(1, (components.day ?? 0) + 1)
    }
    
    /// Vérifie si l'animal a besoin d'attention urgente
    var needsUrgentCare: Bool {
        return hunger < 30 || thirst < 30 || affection < 30
    }
}

// MARK: - Extension Color pour hex

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
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
