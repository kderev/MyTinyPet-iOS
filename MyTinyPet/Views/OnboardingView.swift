//
//  OnboardingView.swift
//  MyTinyPet
//
//  Vue d'accueil pour choisir son animal
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var selectedPetType: PetType?
    @State private var petName: String = ""
    @State private var showNameInput: Bool = false
    @State private var animateTitle: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Titre animé
            VStack(spacing: 8) {
                Text("🐾 MyTinyPet 🐾")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(animateTitle ? 1.05 : 1.0)
                
                Text("Adopte ton compagnon virtuel !")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
            
            // Sélection de l'animal
            if !showNameInput {
                VStack(spacing: 20) {
                    Text("Choisis ton animal")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        ForEach(PetType.allCases) { petType in
                            PetSelectionCard(
                                petType: petType,
                                isSelected: selectedPetType == petType
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedPetType = petType
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Bouton continuer
                    if selectedPetType != nil {
                        Button {
                            withAnimation(.spring()) {
                                showNameInput = true
                            }
                        } label: {
                            HStack {
                                Text("Continuer")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.pink, .purple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            } else {
                // Entrée du nom
                VStack(spacing: 25) {
                    // Aperçu de l'animal choisi
                    if let petType = selectedPetType {
                        PetAvatarView(petType: petType, mood: .happy, size: 120)
                            .transition(.scale)
                    }
                    
                    Text("Comment veux-tu l'appeler ?")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                    
                    // Champ de texte pour le nom
                    TextField("Nom de ton animal", text: $petName)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 5)
                        )
                        .padding(.horizontal, 40)
                    
                    HStack(spacing: 15) {
                        // Bouton retour
                        Button {
                            withAnimation(.spring()) {
                                showNameInput = false
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                                .background(Circle().fill(Color.white).shadow(radius: 3))
                        }
                        
                        // Bouton adopter
                        Button {
                            if let petType = selectedPetType {
                                viewModel.createPet(type: petType, name: petName)
                            }
                        } label: {
                            HStack {
                                Text("Adopter !")
                                Text("🎉")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [.green, .mint],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: .green.opacity(0.3), radius: 10, y: 5)
                        }
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                animateTitle = true
            }
        }
    }
}

// MARK: - Carte de sélection d'animal

struct PetSelectionCard: View {
    let petType: PetType
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            // Avatar de l'animal
            PetAvatarView(petType: petType, mood: .happy, size: 80)
            
            // Nom de l'animal
            Text(petType.displayName)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? petType.primaryColor : Color.white)
                .shadow(
                    color: isSelected ? petType.primaryColor.opacity(0.5) : .black.opacity(0.1),
                    radius: isSelected ? 15 : 5,
                    y: isSelected ? 8 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? petType.secondaryColor : Color.clear, lineWidth: 3)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .onTapGesture {
            onTap()
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(GameViewModel())
}
