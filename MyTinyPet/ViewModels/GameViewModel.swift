//
//  GameViewModel.swift
//  MyTinyPet
//

import Foundation
import SwiftUI
import Combine
import UserNotifications
import UIKit

// MARK: - Animations

enum PetAnimation: String {
    case idle, eating, drinking, loved, sad, celebrate, walking, playing, evolving
}

// MARK: - ViewModel

@MainActor
class GameViewModel: ObservableObject {
    
    @Published var pet: Pet?
    @Published var hasCompletedOnboarding: Bool = false
    @Published var currentAnimation: PetAnimation = .idle
    @Published var statusMessage: String = ""
    
    @Published var totalActionsPerformed: Int = 0
    @Published var totalFeedActions: Int = 0
    @Published var totalDrinkActions: Int = 0
    @Published var totalPetActions: Int = 0
    @Published var totalWalkActions: Int = 0
    @Published var totalPlayActions: Int = 0
    
    @Published var showNameChangeAlert: Bool = false
    @Published var newPetName: String = ""
    @Published var showWalkView: Bool = false
    @Published var showMiniGame: Bool = false
    @Published var showEvolutionAnimation: Bool = false
    @Published var showLevelUpAnimation: Bool = false
    @Published var lastMiniGameScore: Int = 0
    
    private var decayTimer: Timer?
    private var autoSaveTimer: Timer?
    private let persistence = PersistenceManager.shared
    private let baseDecayRate: Double = 0.05
    
    init() {
        loadGame()
        startTimers()
        resetMiniGameCountIfNewDay()
    }
    
    deinit {
        decayTimer?.invalidate()
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Load/Save
    
    func loadGame() {
        let state = persistence.loadGameState()
        self.pet = state.pet
        self.hasCompletedOnboarding = state.hasCompletedOnboarding
        self.totalActionsPerformed = state.totalActionsPerformed
        self.totalFeedActions = state.totalFeedActions
        self.totalDrinkActions = state.totalDrinkActions
        self.totalPetActions = state.totalPetActions
        self.totalWalkActions = state.totalWalkActions
        self.totalPlayActions = state.totalPlayActions
        
        if var loadedPet = self.pet {
            let elapsed = Date().timeIntervalSince(state.lastSaveDate)
            let decay = elapsed * baseDecayRate * loadedPet.evolutionStage.decayMultiplier
            loadedPet.hunger = max(0, loadedPet.hunger - decay)
            loadedPet.thirst = max(0, loadedPet.thirst - decay)
            loadedPet.affection = max(0, loadedPet.affection - decay * 0.5)
            loadedPet.bladder = max(0, loadedPet.bladder - decay * 0.7)
            self.pet = loadedPet
        }
        updateStatusMessage()
    }
    
    func saveGame() {
        let state = GameState(
            pet: pet,
            hasCompletedOnboarding: hasCompletedOnboarding,
            totalActionsPerformed: totalActionsPerformed,
            totalFeedActions: totalFeedActions,
            totalDrinkActions: totalDrinkActions,
            totalPetActions: totalPetActions,
            totalWalkActions: totalWalkActions,
            totalPlayActions: totalPlayActions,
            lastSaveDate: Date()
        )
        persistence.saveGameState(state)
    }
    
    func resetGame() {
        stopTimers()
        pet = nil
        hasCompletedOnboarding = false
        totalActionsPerformed = 0
        totalFeedActions = 0
        totalDrinkActions = 0
        totalPetActions = 0
        totalWalkActions = 0
        totalPlayActions = 0
        persistence.resetGameState()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        startTimers()
    }
    
    // MARK: - Pet Creation
    
    func createPet(type: PetType, name: String = "") {
        let petName = name.isEmpty ? type.displayName : name
        pet = Pet(name: petName, type: type)
        hasCompletedOnboarding = true
        currentAnimation = .celebrate
        statusMessage = "Bienvenue \(petName) ! 🎉"
        saveGame()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.currentAnimation = .idle
            self?.updateStatusMessage()
        }
    }
    
    func changePetName(to newName: String) {
        guard !newName.isEmpty else { return }
        pet?.name = newName
        statusMessage = "Ton animal s'appelle maintenant \(newName) !"
        saveGame()
    }
    
    // MARK: - Actions
    
    func performAction(_ action: PetAction) {
        guard var currentPet = pet else { return }
        
        let multiplier: Double = {
            switch currentPet.evolutionStage {
            case .baby: return 0.8
            case .child: return 0.9
            case .adult: return 1.0
            case .senior: return 1.1
            }
        }()
        let amount = 25.0 * multiplier
        
        switch action {
        case .feed:
            currentPet.hunger = min(100, currentPet.hunger + amount)
            totalFeedActions += 1
            currentAnimation = .eating
            statusMessage = "Miam miam ! 🍎"
        case .drink:
            currentPet.thirst = min(100, currentPet.thirst + amount)
            totalDrinkActions += 1
            currentAnimation = .drinking
            statusMessage = "Glou glou ! 💧"
        case .pet:
            currentPet.affection = min(100, currentPet.affection + amount)
            totalPetActions += 1
            currentAnimation = .loved
            statusMessage = "Ronron... ❤️"
        case .walk:
            showWalkView = true
            return
        case .play:
            if currentPet.canPlayMiniGame {
                showMiniGame = true
            } else {
                statusMessage = "Déjà 3 parties aujourd'hui ! 🎮"
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            }
            return
        }
        
        currentPet.xp += action.xpReward
        checkLevelUp(for: &currentPet)
        currentPet.lastInteractionDate = Date()
        pet = currentPet
        totalActionsPerformed += 1
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        saveGame()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.currentAnimation = .idle
            self?.updateStatusMessage()
        }
    }
    
    // MARK: - Walk
    
    func completeWalk(duration: TimeInterval, poopCount: Int) {
        guard var currentPet = pet else { return }
        
        let bladderBonus = min(100, 30 + (duration / 60) * 10)
        let affectionBonus = 10 + (duration / 60) * 5
        let xpBonus = Int(15 + Double(poopCount) * 5)
        
        currentPet.bladder = min(100, currentPet.bladder + bladderBonus)
        currentPet.affection = min(100, currentPet.affection + affectionBonus)
        currentPet.totalWalks += 1
        currentPet.lastWalkDate = Date()
        currentPet.xp += xpBonus
        
        checkLevelUp(for: &currentPet)
        
        pet = currentPet
        totalWalkActions += 1
        totalActionsPerformed += 1
        currentAnimation = .walking
        statusMessage = "Super promenade ! 🌳 (+\(xpBonus) XP)"
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        saveGame()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.currentAnimation = .idle
            self?.updateStatusMessage()
        }
    }
    
    // MARK: - Mini-Game
    
    func completeMiniGame(score: Int) {
        guard var currentPet = pet else { return }
        
        lastMiniGameScore = score
        let affectionBonus = Double(score) / 10.0
        let xpBonus = 20 + score / 5
        
        currentPet.affection = min(100, currentPet.affection + affectionBonus)
        currentPet.miniGamesPlayedToday += 1
        currentPet.totalMiniGamesPlayed += 1
        currentPet.lastMiniGameDate = Date()
        currentPet.xp += xpBonus
        
        if score > currentPet.highScore {
            currentPet.highScore = score
            statusMessage = "Nouveau record : \(score) ! 🏆"
        } else {
            statusMessage = "Bien joué ! Score: \(score) 🎮"
        }
        
        checkLevelUp(for: &currentPet)
        
        pet = currentPet
        totalPlayActions += 1
        totalActionsPerformed += 1
        currentAnimation = .celebrate
        
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        saveGame()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.currentAnimation = .idle
            self?.updateStatusMessage()
        }
    }
    
    private func resetMiniGameCountIfNewDay() {
        guard var currentPet = pet, let lastGame = currentPet.lastMiniGameDate else { return }
        if !Calendar.current.isDateInToday(lastGame) {
            currentPet.miniGamesPlayedToday = 0
            pet = currentPet
            saveGame()
        }
    }
    
    // MARK: - Level & Evolution
    
    private func checkLevelUp(for pet: inout Pet) {
        while pet.xp >= pet.xpForNextLevel {
            pet.xp -= pet.xpForNextLevel
            pet.level += 1
            
            let newLevel = pet.level
            DispatchQueue.main.async { [weak self] in
                self?.showLevelUpAnimation = true
                self?.statusMessage = "Niveau \(newLevel) atteint ! 🎉"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self?.showLevelUpAnimation = false
                }
            }
            
            checkEvolution(for: &pet)
        }
    }
    
    private func checkEvolution(for pet: inout Pet) {
        guard let nextStage = pet.evolutionStage.nextStage,
              pet.level >= nextStage.requiredLevel else { return }
        
        pet.evolutionStage = nextStage
        let name = pet.name
        let stage = nextStage.rawValue
        let emoji = nextStage.emoji
        
        DispatchQueue.main.async { [weak self] in
            self?.showEvolutionAnimation = true
            self?.currentAnimation = .evolving
            self?.statusMessage = "\(name) a évolué en \(stage) ! \(emoji)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self?.showEvolutionAnimation = false
                self?.currentAnimation = .idle
            }
        }
    }
    
    // MARK: - Timers
    
    private func startTimers() {
        decayTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.updatePetStats() }
        }
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.saveGame() }
        }
    }
    
    private func stopTimers() {
        decayTimer?.invalidate()
        autoSaveTimer?.invalidate()
    }
    
    private func updatePetStats() {
        guard var currentPet = pet else { return }
        let rate = baseDecayRate * currentPet.evolutionStage.decayMultiplier
        currentPet.hunger = max(0, currentPet.hunger - rate)
        currentPet.thirst = max(0, currentPet.thirst - rate)
        currentPet.affection = max(0, currentPet.affection - rate * 0.3)
        currentPet.bladder = max(0, currentPet.bladder - rate * 0.6)
        pet = currentPet
    }
    
    private func updateStatusMessage() {
        statusMessage = pet?.currentMood.statusMessage ?? ""
    }
}
