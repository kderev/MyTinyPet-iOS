//
//  MainGameView.swift
//  MyTinyPet
//
//  Vue principale du jeu avec l'animal et les actions
//

import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showSettings: Bool = false
    @State private var showStats: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header avec infos
            HeaderView(showSettings: $showSettings, showStats: $showStats)
            
            Spacer()
            
            // Zone centrale avec l'animal
            if let pet = viewModel.pet {
                PetDisplayView(pet: pet)
            }
            
            Spacer()
            
            // Jauges de statut
            StatusBarsView()
            
            // Boutons d'actions
            ActionButtonsView()
                .padding(.bottom, 30)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showStats) {
            StatsView()
        }
        .alert("Renommer ton animal", isPresented: $viewModel.showNameChangeAlert) {
            TextField("Nouveau nom", text: $viewModel.newPetName)
            Button("Annuler", role: .cancel) { }
            Button("Confirmer") {
                viewModel.changePetName(to: viewModel.newPetName)
            }
        } message: {
            Text("Entre le nouveau nom de ton compagnon")
        }
    }
}

// MARK: - Header

struct HeaderView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Binding var showSettings: Bool
    @Binding var showStats: Bool
    
    var body: some View {
        HStack {
            // Compteur de jours
            VStack(alignment: .leading, spacing: 2) {
                Text("Jour")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(viewModel.pet?.daysSinceCreation ?? 1)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
            }
            .padding(.leading)
            
            Spacer()
            
            // Nom de l'animal (cliquable)
            if let pet = viewModel.pet {
                Button {
                    viewModel.newPetName = pet.name
                    viewModel.showNameChangeAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Text(pet.name)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption)
                    }
                    .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Boutons menu
            HStack(spacing: 12) {
                Button {
                    showStats = true
                } label: {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                }
                
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.trailing)
        }
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.white.opacity(0.8))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
}

// MARK: - Affichage de l'animal

struct PetDisplayView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let pet: Pet
    
    @State private var bounceAnimation: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Avatar de l'animal avec animations
            ZStack {
                // Cercle de fond
                Circle()
                    .fill(pet.type.primaryColor.opacity(0.2))
                    .frame(width: 250, height: 250)
                
                // Animal
                PetAvatarView(
                    petType: pet.type,
                    mood: pet.currentMood,
                    size: 180,
                    animation: viewModel.currentAnimation
                )
                .offset(y: bounceAnimation ? -10 : 0)
            }
            
            // Message de statut
            Text(viewModel.statusMessage)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .transition(.opacity)
                .id(viewModel.statusMessage) // Force refresh on change
            
            // Indicateur d'humeur
            HStack(spacing: 8) {
                Text(pet.currentMood.emoji)
                    .font(.title)
                Text(pet.currentMood.rawValue.capitalized)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 5)
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                bounceAnimation = true
            }
        }
        .onChange(of: viewModel.currentAnimation) { _, newAnimation in
            if newAnimation != .idle {
                // Animation de réaction
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    bounceAnimation = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        bounceAnimation = true
                    }
                }
            }
        }
    }
}

// MARK: - Barres de statut

struct StatusBarsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        if let pet = viewModel.pet {
            VStack(spacing: 12) {
                StatusBar(
                    label: "Faim",
                    icon: "🍎",
                    value: pet.hunger,
                    color: .orange
                )
                
                StatusBar(
                    label: "Soif",
                    icon: "💧",
                    value: pet.thirst,
                    color: .blue
                )
                
                StatusBar(
                    label: "Affection",
                    icon: "❤️",
                    value: pet.affection,
                    color: .pink
                )
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 10)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct StatusBar: View {
    let label: String
    let icon: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(label)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(value))%")
                        .font(.caption.weight(.bold))
                        .foregroundColor(value < 30 ? .red : .secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Fond
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                        
                        // Barre de progression
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.7), color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(value / 100))
                            .animation(.spring(response: 0.5), value: value)
                    }
                }
                .frame(height: 10)
            }
        }
    }
}

// MARK: - Boutons d'actions

struct ActionButtonsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        HStack(spacing: 25) {
            ForEach(PetAction.allCases, id: \.self) { action in
                ActionButton(action: action) {
                    viewModel.performAction(action)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct ActionButton: View {
    let action: PetAction
    let onTap: () -> Void
    
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button {
            isPressed = true
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        } label: {
            VStack(spacing: 8) {
                Text(action.icon)
                    .font(.system(size: 36))
                
                Text(action.displayName)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [action.color, action.color.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(
                        color: action.color.opacity(0.4),
                        radius: isPressed ? 5 : 10,
                        y: isPressed ? 2 : 5
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.2), value: isPressed)
    }
}

#Preview {
    MainGameView()
        .environmentObject({
            let vm = GameViewModel()
            vm.createPet(type: .pig, name: "Pinky")
            return vm
        }())
}
