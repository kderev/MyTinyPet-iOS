//
//  MyTinyPetApp.swift
//  MyTinyPet
//

import SwiftUI
import UserNotifications

@main
struct MyTinyPetApp: App {
    @StateObject private var viewModel = GameViewModel()
    
    init() {
        requestNotificationPermission()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("✅ Notifications autorisées")
            }
        }
    }
}
