//
//  ContentView.swift
//  MyTinyPet
//
//  Vue principale qui gère la navigation entre onboarding et jeu
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            // Fond dégradé global
            LinearGradient(
                colors: [
                    Color(hex: "E8F5E9"),
                    Color(hex: "FFF3E0")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Contenu principal
            if viewModel.hasCompletedOnboarding && viewModel.pet != nil {
                MainGameView()
                    .transition(.opacity.combined(with: .scale))
            } else {
                OnboardingView()
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.hasCompletedOnboarding)
    }
}

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
