//
//  MyTinyPetApp.swift
//  MyTinyPet
//
//  Un jeu de type Tamagotchi où vous prenez soin d'un animal virtuel
//

import SwiftUI
import UserNotifications

@main
struct MyTinyPetApp: App {
    // ViewModel partagé pour toute l'application
    @StateObject private var gameViewModel = GameViewModel()
    
    init() {
        // Demander la permission pour les notifications locales
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameViewModel)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // Sauvegarder quand l'app passe en arrière-plan
                    gameViewModel.saveGame()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // Sauvegarder avant la fermeture
                    gameViewModel.saveGame()
                }
        }
    }
    
    /// Demande la permission d'envoyer des notifications locales
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notifications autorisées")
            } else if let error = error {
                print("❌ Erreur notifications: \(error.localizedDescription)")
            }
        }
    }
}
