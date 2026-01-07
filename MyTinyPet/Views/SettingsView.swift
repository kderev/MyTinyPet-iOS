//
//  SettingsView.swift
//  MyTinyPet
//
//  Vue des paramètres du jeu
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showResetConfirmation: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                // Section Animal
                if let pet = viewModel.pet {
                    Section {
                        HStack {
                            PetAvatarView(petType: pet.type, mood: pet.currentMood, size: 60)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pet.name)
                                    .font(.headline)
                                Text(pet.type.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 10)
                            
                            Spacer()
                            
                            Button {
                                viewModel.newPetName = pet.name
                                viewModel.showNameChangeAlert = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Mon Animal")
                    }
                }
                
                // Section Notifications
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        Text("Notifications")
                        
                        Spacer()
                        
                        Button("Configurer") {
                            openNotificationSettings()
                        }
                        .font(.subheadline)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Les notifications te rappellent de prendre soin de ton animal.")
                }
                
                // Section À propos
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                            .frame(width: 30)
                        Text("Fait avec amour")
                        Spacer()
                        Text("🐾")
                    }
                } header: {
                    Text("À propos")
                }
                
                // Section Danger
                Section {
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash.fill")
                                .frame(width: 30)
                            Text("Réinitialiser le jeu")
                        }
                    }
                } header: {
                    Text("Zone Danger")
                } footer: {
                    Text("Cette action supprimera définitivement ton animal et toutes tes données.")
                }
            }
            .navigationTitle("Paramètres")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
            .alert("Réinitialiser le jeu ?", isPresented: $showResetConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Réinitialiser", role: .destructive) {
                    viewModel.resetGame()
                    dismiss()
                }
            } message: {
                Text("Tu vas perdre ton animal \(viewModel.pet?.name ?? "") et toutes tes statistiques. Cette action est irréversible.")
            }
        }
    }
    
    private func openNotificationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject({
            let vm = GameViewModel()
            vm.createPet(type: .dog, name: "Max")
            return vm
        }())
}
