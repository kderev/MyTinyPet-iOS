//
//  GameState.swift
//  MyTinyPet
//
//  Modèle pour la sauvegarde de l'état du jeu
//

import Foundation

/// Structure contenant l'état complet du jeu pour la sauvegarde
struct GameState: Codable {
    var pet: Pet?
    var hasCompletedOnboarding: Bool
    var totalActionsPerformed: Int
    var totalFeedActions: Int
    var totalDrinkActions: Int
    var totalPetActions: Int
    var lastSaveDate: Date
    
    /// État initial du jeu
    static var initial: GameState {
        GameState(
            pet: nil,
            hasCompletedOnboarding: false,
            totalActionsPerformed: 0,
            totalFeedActions: 0,
            totalDrinkActions: 0,
            totalPetActions: 0,
            lastSaveDate: Date()
        )
    }
}

// MARK: - Gestionnaire de persistance

/// Classe gérant la sauvegarde et le chargement des données
class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults = UserDefaults.standard
    private let gameStateKey = "MyTinyPet_GameState"
    
    private init() {}
    
    /// Sauvegarde l'état du jeu
    func saveGameState(_ state: GameState) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(state)
            userDefaults.set(data, forKey: gameStateKey)
            print("💾 Jeu sauvegardé avec succès")
        } catch {
            print("❌ Erreur de sauvegarde: \(error.localizedDescription)")
        }
    }
    
    /// Charge l'état du jeu
    func loadGameState() -> GameState {
        guard let data = userDefaults.data(forKey: gameStateKey) else {
            print("📭 Aucune sauvegarde trouvée, création d'un nouvel état")
            return .initial
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let state = try decoder.decode(GameState.self, from: data)
            print("📂 Jeu chargé avec succès")
            return state
        } catch {
            print("❌ Erreur de chargement: \(error.localizedDescription)")
            return .initial
        }
    }
    
    /// Supprime toutes les données sauvegardées
    func resetGameState() {
        userDefaults.removeObject(forKey: gameStateKey)
        print("🗑️ Données du jeu supprimées")
    }
}
