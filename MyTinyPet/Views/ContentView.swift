//
//  ContentView.swift
//  MyTinyPet
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        Group {
            if viewModel.hasCompletedOnboarding {
                MainGameView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut, value: viewModel.hasCompletedOnboarding)
    }
}
