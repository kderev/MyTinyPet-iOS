//
//  GameViewModel.swift
//  MyTinyPet
//
//  ViewModel principal gérant la logique du jeu (MVVM)
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

/// ViewModel principal du jeu, gère tous les états et la logique
@MainActor
class GameViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// L'animal du joueur (nil si pas encore choisi)
    @Published var pet: Pet?
    
    /// Indique si l'onboarding est terminé
    @Published var hasCompletedOnboarding: Bool = false
    
    /// Animation en cours (pour les réactions)
    @Published var currentAnimation: PetAnimation = .idle
    
    /// Message temporaire à afficher
    @Published var statusMessage: String = ""
    
    /// Statistiques du jeu
    @Published var totalActionsPerformed: Int = 0
    @Published var totalFeedActions: Int = 0
    @Published var totalDrinkActions: Int = 0
    @Published var totalPetActions: Int = 0
    
    /// Afficher le popup de changement de nom
    @Published var showNameChangeAlert: Bool = false
    @Published var newPetName: String = ""
    
    // MARK: - Private Properties
    
    /// Timer pour la diminution des jauges
    private var decayTimer: Timer?
    
    /// Timer pour la sauvegarde automatique
    private var autoSaveTimer: Timer?
    
    /// Gestionnaire de persistance
    private let persistence = PersistenceManager.shared
    
    /// Vitesse de diminution des jauges (points par seconde)
    private let decayRate: Double = 0.05  // ~3 points par minute
    
    /// Intervalle de mise à jour (en secondes)
    private let updateInterval: TimeInterval = 1.0
    
    /// Intervalle de sauvegarde automatique (en secondes)
    private let autoSaveInterval: TimeInterval = 30.0
    
    // MARK: - Initialization
    
    init() {
        loadGame()
        startTimers()
    }
    
    deinit {
        decayTimer?.invalidate()
        autoSaveTimer?.invalidate()
    }
    
    // MARK: - Game State Management
    
    /// Charge l'état du jeu depuis la persistance
    func loadGame() {
        let state = persistence.loadGameState()
        
        self.pet = state.pet
        self.hasCompletedOnboarding = state.hasCompletedOnboarding
        self.totalActionsPerformed = state.totalActionsPerformed
        self.totalFeedActions = state.totalFeedActions
        self.totalDrinkActions = state.totalDrinkActions
        self.totalPetActions = state.totalPetActions
        
        // Calculer la dégradation pendant l'absence
        if var loadedPet = self.pet {
            let timeSinceLastSave = Date().timeIntervalSince(state.lastSaveDate)
            let decayAmount = timeSinceLastSave * decayRate
            
            loadedPet.hunger = max(0, loadedPet.hunger - decayAmount)
            loadedPet.thirst = max(0, loadedPet.thirst - decayAmount)
            loadedPet.affection = max(0, loadedPet.affection - decayAmount * 0.5)
            loadedPet.lastInteractionDate = Date()
            
            self.pet = loadedPet
            
            print("⏰ Temps écoulé: \(Int(timeSinceLastSave))s, dégradation: \(Int(decayAmount)) points")
        }
        
        updateStatusMessage()
    }
    
    /// Sauvegarde l'état du jeu
    func saveGame() {
        let state = GameState(
            pet: pet,
            hasCompletedOnboarding: hasCompletedOnboarding,
            totalActionsPerformed: totalActionsPerformed,
            totalFeedActions: totalFeedActions,
            totalDrinkActions: totalDrinkActions,
            totalPetActions: totalPetActions,
            lastSaveDate: Date()
        )
        persistence.saveGameState(state)
    }
    
    /// Réinitialise le jeu complètement
    func resetGame() {
        stopTimers()
        pet = nil
        hasCompletedOnboarding = false
        totalActionsPerformed = 0
        totalFeedActions = 0
        totalDrinkActions = 0
        totalPetActions = 0
        persistence.resetGameState()
        cancelAllNotifications()
        startTimers()
    }
    
    // MARK: - Pet Creation
    
    /// Crée un nouvel animal avec le type choisi
    func createPet(type: PetType, name: String = "") {
        let petName = name.isEmpty ? "\(type.displayName)" : name
        pet = Pet(name: petName, type: type)
        hasCompletedOnboarding = true
        
        currentAnimation = .celebrate
        statusMessage = "Bienvenue \(petName) ! 🎉"
        
        saveGame()
        scheduleReminders()
        
        // Reset animation après délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.currentAnimation = .idle
        }
    }
    
    /// Change le nom de l'animal
    func changePetName(to newName: String) {
        guard !newName.isEmpty else { return }
        pet?.name = newName
        statusMessage = "Ton animal s'appelle maintenant \(newName) !"
        saveGame()
    }
    
    // MARK: - Pet Actions
    
    /// Effectue une action sur l'animal
    func performAction(_ action: PetAction) {
        guard var currentPet = pet else { return }
        
        let increaseAmount: Double = 25.0
        
        switch action {
        case .feed:
            currentPet.hunger = min(100, currentPet.hunger + increaseAmount)
            totalFeedActions += 1
            currentAnimation = .eating
            statusMessage = "Miam miam ! 🍎"
            
        case .drink:
            currentPet.thirst = min(100, currentPet.thirst + increaseAmount)
            totalDrinkActions += 1
            currentAnimation = .drinking
            statusMessage = "Glou glou ! 💧"
            
        case .pet:
            currentPet.affection = min(100, currentPet.affection + increaseAmount)
            totalPetActions += 1
            currentAnimation = .loved
            statusMessage = "Ronron... ❤️"
        }
        
        currentPet.lastInteractionDate = Date()
        pet = currentPet
        totalActionsPerformed += 1
        
        // Feedback haptique
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        saveGame()
        
        // Reset animation après délai
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.currentAnimation = .idle
            self?.updateStatusMessage()
        }
    }
    
    // MARK: - Timers
    
    /// Démarre les timers du jeu
    private func startTimers() {
        // Timer de dégradation des jauges
        decayTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePetStats()
            }
        }
        
        // Timer de sauvegarde automatique
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveInterval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.saveGame()
            }
        }
    }
    
    /// Arrête tous les timers
    private func stopTimers() {
        decayTimer?.invalidate()
        decayTimer = nil
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    /// Met à jour les statistiques de l'animal (appelé par le timer)
    private func updatePetStats() {
        guard var currentPet = pet else { return }
        
        // Diminution progressive des jauges
        currentPet.hunger = max(0, currentPet.hunger - decayRate)
        currentPet.thirst = max(0, currentPet.thirst - decayRate)
        currentPet.affection = max(0, currentPet.affection - (decayRate * 0.3))
        
        pet = currentPet
        
        // Vérifier si des notifications urgentes sont nécessaires
        if currentPet.hunger < 15 || currentPet.thirst < 15 {
            scheduleUrgentNotification()
        }
    }
    
    /// Met à jour le message de statut basé sur l'humeur
    private func updateStatusMessage() {
        guard let currentPet = pet else {
            statusMessage = ""
            return
        }
        statusMessage = currentPet.currentMood.statusMessage
    }
    
    // MARK: - Notifications
    
    /// Programme les rappels de notification
    private func scheduleReminders() {
        cancelAllNotifications()
        
        let content = UNMutableNotificationContent()
        content.title = "🐾 MyTinyPet"
        content.body = "Ton animal a besoin de toi ! Viens lui rendre visite."
        content.sound = .default
        
        // Notification après 4 heures d'inactivité
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 3600, repeats: false)
        let request = UNNotificationRequest(identifier: "petReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Programme une notification urgente
    private func scheduleUrgentNotification() {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Urgence MyTinyPet"
        content.body = "Ton animal a vraiment besoin de soins !"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: "urgentReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Annule toutes les notifications programmées
    private func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Animations

/// Types d'animations pour l'animal
enum PetAnimation: String {
    case idle = "repos"
    case eating = "mange"
    case drinking = "boit"
    case loved = "aimé"
    case sad = "triste"
    case celebrate = "célèbre"
    
    /// Durée de l'animation en secondes
    var duration: Double {
        switch self {
        case .idle: return 0
        case .eating, .drinking, .loved: return 1.5
        case .sad: return 2.0
        case .celebrate: return 2.0
        }
    }
}
