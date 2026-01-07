//
//  NotificationManager.swift
//  MyTinyPet
//
//  Gestionnaire des notifications locales
//

import Foundation
import UserNotifications

/// Gestionnaire centralisé pour les notifications locales
class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Types de notifications
    
    enum NotificationType: String {
        case hungry = "pet_hungry"
        case thirsty = "pet_thirsty"
        case lonely = "pet_lonely"
        case dailyReminder = "daily_reminder"
        case urgentCare = "urgent_care"
        
        var title: String {
            switch self {
            case .hungry: return "🍎 Ton animal a faim !"
            case .thirsty: return "💧 Ton animal a soif !"
            case .lonely: return "❤️ Ton animal s'ennuie..."
            case .dailyReminder: return "🐾 Coucou !"
            case .urgentCare: return "⚠️ Urgence !"
            }
        }
        
        var body: String {
            switch self {
            case .hungry: return "Viens lui donner à manger, il attend avec impatience !"
            case .thirsty: return "N'oublie pas de lui donner à boire !"
            case .lonely: return "Ton petit compagnon aimerait des câlins..."
            case .dailyReminder: return "Ton animal t'attend ! Viens lui rendre visite."
            case .urgentCare: return "Ton animal a vraiment besoin de toi maintenant !"
            }
        }
    }
    
    // MARK: - Permissions
    
    /// Demande la permission d'envoyer des notifications
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Erreur permission notifications: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    /// Vérifie si les notifications sont autorisées
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Programmation des notifications
    
    /// Programme une notification après un délai
    func scheduleNotification(
        type: NotificationType,
        delay: TimeInterval,
        petName: String? = nil
    ) {
        let content = UNMutableNotificationContent()
        content.title = type.title
        
        // Personnaliser le message avec le nom de l'animal
        if let name = petName {
            content.body = type.body.replacingOccurrences(of: "Ton animal", with: name)
        } else {
            content.body = type.body
        }
        
        content.sound = .default
        content.badge = 1
        
        // Trigger basé sur le délai
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, delay),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: type.rawValue,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur programmation notification: \(error.localizedDescription)")
            } else {
                print("✅ Notification \(type.rawValue) programmée dans \(Int(delay))s")
            }
        }
    }
    
    /// Programme une notification quotidienne à une heure fixe
    func scheduleDailyReminder(hour: Int, minute: Int, petName: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = NotificationType.dailyReminder.title
        
        if let name = petName {
            content.body = "\(name) t'attend ! Viens lui rendre visite."
        } else {
            content.body = NotificationType.dailyReminder.body
        }
        
        content.sound = .default
        
        // Trigger quotidien
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Erreur rappel quotidien: \(error.localizedDescription)")
            } else {
                print("✅ Rappel quotidien programmé à \(hour):\(minute)")
            }
        }
    }
    
    // MARK: - Gestion des notifications
    
    /// Annule une notification spécifique
    func cancelNotification(type: NotificationType) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [type.rawValue]
        )
        print("🗑️ Notification \(type.rawValue) annulée")
    }
    
    /// Annule toutes les notifications en attente
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("🗑️ Toutes les notifications annulées")
    }
    
    /// Efface le badge de l'app
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("❌ Erreur effacement badge: \(error.localizedDescription)")
            }
        }
    }
    
    /// Liste toutes les notifications en attente (pour debug)
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("📋 Notifications en attente: \(requests.count)")
            for request in requests {
                print("  - \(request.identifier): \(request.content.title)")
            }
        }
    }
}

// MARK: - Extension pour programmer les rappels du jeu

extension NotificationManager {
    
    /// Programme les rappels automatiques basés sur l'état de l'animal
    func scheduleGameReminders(pet: Pet) {
        cancelAllNotifications()
        
        // Rappel si faim basse (dans 2 heures si > 50%, sinon dans 30 min)
        let hungerDelay: TimeInterval = pet.hunger > 50 ? 7200 : 1800
        scheduleNotification(type: .hungry, delay: hungerDelay, petName: pet.name)
        
        // Rappel si soif basse
        let thirstDelay: TimeInterval = pet.thirst > 50 ? 7200 : 1800
        scheduleNotification(type: .thirsty, delay: thirstDelay, petName: pet.name)
        
        // Rappel affection (4 heures)
        scheduleNotification(type: .lonely, delay: 14400, petName: pet.name)
        
        // Rappel quotidien à 18h
        scheduleDailyReminder(hour: 18, minute: 0, petName: pet.name)
    }
}
