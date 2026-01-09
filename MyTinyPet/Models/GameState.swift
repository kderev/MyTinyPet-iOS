//
//  GameState.swift
//  MyTinyPet
//

import Foundation

struct GameState: Codable {
    var pet: Pet?
    var hasCompletedOnboarding: Bool
    var totalActionsPerformed: Int
    var totalFeedActions: Int
    var totalDrinkActions: Int
    var totalPetActions: Int
    var totalWalkActions: Int
    var totalPlayActions: Int
    var lastSaveDate: Date
    
    static var initial: GameState {
        GameState(
            pet: nil,
            hasCompletedOnboarding: false,
            totalActionsPerformed: 0,
            totalFeedActions: 0,
            totalDrinkActions: 0,
            totalPetActions: 0,
            totalWalkActions: 0,
            totalPlayActions: 0,
            lastSaveDate: Date()
        )
    }
}

// MARK: - Persistence Manager

class PersistenceManager {
    static let shared = PersistenceManager()
    private let gameStateKey = "MyTinyPet_GameState"
    
    private init() {}
    
    func saveGameState(_ state: GameState) {
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: gameStateKey)
        } catch {
            print("❌ Erreur sauvegarde: \(error)")
        }
    }
    
    func loadGameState() -> GameState {
        guard let data = UserDefaults.standard.data(forKey: gameStateKey) else {
            return .initial
        }
        do {
            return try JSONDecoder().decode(GameState.self, from: data)
        } catch {
            print("❌ Erreur chargement: \(error)")
            return .initial
        }
    }
    
    func resetGameState() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
    }
}
