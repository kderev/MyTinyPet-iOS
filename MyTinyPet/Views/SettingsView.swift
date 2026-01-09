//
//  SettingsView.swift
//  MyTinyPet
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Animal") {
                    if let pet = viewModel.pet {
                        HStack {
                            Text("Nom")
                            Spacer()
                            Text(pet.name).foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Type")
                            Spacer()
                            Text("\(pet.type.emoji) \(pet.type.displayName)").foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Niveau")
                            Spacer()
                            Text("\(pet.level)").foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Stade")
                            Spacer()
                            Text("\(pet.evolutionStage.emoji) \(pet.evolutionStage.rawValue.capitalized)").foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Données") {
                    Button(role: .destructive) {
                        showResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Réinitialiser le jeu")
                        }
                    }
                }
                
                Section("À propos") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
            .alert("Réinitialiser ?", isPresented: $showResetAlert) {
                Button("Annuler", role: .cancel) {}
                Button("Réinitialiser", role: .destructive) {
                    viewModel.resetGame()
                    dismiss()
                }
            } message: {
                Text("Tu perdras ton animal et toute ta progression.")
            }
        }
    }
}
