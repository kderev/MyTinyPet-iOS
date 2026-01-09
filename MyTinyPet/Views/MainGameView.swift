//
//  MainGameView.swift
//  MyTinyPet
//

import SwiftUI

struct MainGameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var showSettings = false
    @State private var showStats = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "E8F5E9"), Color(hex: "FFF8E1")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView(showSettings: $showSettings, showStats: $showStats)
                
                Spacer()
                
                if let pet = viewModel.pet {
                    PetDisplayView(pet: pet)
                }
                
                Spacer()
                
                StatusBarsView()
                ActionButtonsView()
                    .padding(.bottom, 20)
            }
            
            if viewModel.showLevelUpAnimation {
                LevelUpOverlay()
            }
            
            if viewModel.showEvolutionAnimation {
                EvolutionOverlay()
            }
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
        .sheet(isPresented: $showStats) { StatsView() }
        .fullScreenCover(isPresented: $viewModel.showWalkView) { WalkView() }
        .fullScreenCover(isPresented: $viewModel.showMiniGame) { MiniGameView() }
        .alert("Renommer ton animal", isPresented: $viewModel.showNameChangeAlert) {
            TextField("Nouveau nom", text: $viewModel.newPetName)
            Button("Annuler", role: .cancel) {}
            Button("Confirmer") { viewModel.changePetName(to: viewModel.newPetName) }
        }
    }
}

// MARK: - Header

struct HeaderView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Binding var showSettings: Bool
    @Binding var showStats: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Jour \(viewModel.pet?.daysSinceCreation ?? 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let pet = viewModel.pet {
                        HStack(spacing: 4) {
                            Text("Niv. \(pet.level)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                            Text(pet.evolutionStage.emoji)
                        }
                    }
                }
                .padding(.leading)
                
                Spacer()
                
                if let pet = viewModel.pet {
                    Button {
                        viewModel.newPetName = pet.name
                        viewModel.showNameChangeAlert = true
                    } label: {
                        VStack(spacing: 2) {
                            HStack(spacing: 4) {
                                Text(pet.name)
                                    .font(.system(size: 18, weight: .semibold))
                                Image(systemName: "pencil.circle.fill")
                                    .font(.caption2)
                            }
                            Text(pet.evolutionStage.rawValue.capitalized)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button { showStats = true } label: {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.purple)
                    }
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.gray)
                    }
                }
                .font(.title3)
                .padding(.trailing)
            }
            
            if let pet = viewModel.pet {
                XPBarView(xp: pet.xp, maxXP: pet.xpForNextLevel)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.9))
    }
}

struct XPBarView: View {
    let xp: Int
    let maxXP: Int
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("XP").font(.caption2.bold()).foregroundColor(.purple)
                Spacer()
                Text("\(xp)/\(maxXP)").font(.caption2).foregroundColor(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.purple.opacity(0.2))
                    Capsule()
                        .fill(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(xp) / CGFloat(maxXP))
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Pet Display

struct PetDisplayView: View {
    @EnvironmentObject var viewModel: GameViewModel
    let pet: Pet
    @State private var float = false
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(pet.type.primaryColor.opacity(0.15))
                    .frame(width: 240, height: 240)
                    .scaleEffect(float ? 1.02 : 1.0)
                
                PetAvatarView(
                    petType: pet.type,
                    mood: pet.currentMood,
                    size: 160 * pet.evolutionStage.sizeMultiplier,
                    animation: viewModel.currentAnimation
                )
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    float = true
                }
            }
            
            Text(viewModel.statusMessage)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .id(viewModel.statusMessage)
            
            HStack(spacing: 15) {
                HStack(spacing: 6) {
                    Text(pet.currentMood.emoji)
                    Text(pet.currentMood.rawValue.capitalized)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white).shadow(radius: 3))
                
                if pet.canPlayMiniGame {
                    HStack(spacing: 4) {
                        Text("🎮")
                        Text("\(3 - pet.miniGamesPlayedToday)")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.purple.opacity(0.15)))
                }
            }
        }
    }
}

// MARK: - Status Bars

struct StatusBarsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        if let pet = viewModel.pet {
            VStack(spacing: 10) {
                HStack(spacing: 15) {
                    MiniStatusBar(icon: "🍎", value: pet.hunger, color: .orange)
                    MiniStatusBar(icon: "💧", value: pet.thirst, color: .blue)
                }
                HStack(spacing: 15) {
                    MiniStatusBar(icon: "❤️", value: pet.affection, color: .pink)
                    MiniStatusBar(icon: "🚽", value: pet.bladder, color: .green)
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(radius: 5)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct MiniStatusBar: View {
    let icon: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Text(icon).font(.system(size: 18))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.2))
                    Capsule()
                        .fill(LinearGradient(colors: [color.opacity(0.7), color], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, geo.size.width * value / 100))
                }
            }
            .frame(height: 8)
            Text("\(Int(value))")
                .font(.caption2.bold())
                .foregroundColor(value < 30 ? .red : .secondary)
                .frame(width: 25, alignment: .trailing)
        }
    }
}

// MARK: - Actions

struct ActionButtonsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 15) {
                SmallActionButton(action: .feed) { viewModel.performAction(.feed) }
                SmallActionButton(action: .drink) { viewModel.performAction(.drink) }
                SmallActionButton(action: .pet) { viewModel.performAction(.pet) }
            }
            HStack(spacing: 15) {
                WideActionButton(action: .walk) { viewModel.performAction(.walk) }
                WideActionButton(action: .play) { viewModel.performAction(.play) }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

struct SmallActionButton: View {
    let action: PetAction
    let onTap: () -> Void
    @State private var pressed = false
    
    var body: some View {
        Button {
            pressed = true
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { pressed = false }
        } label: {
            VStack(spacing: 6) {
                Text(action.icon).font(.system(size: 28))
                Text(action.displayName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 85, height: 75)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(LinearGradient(colors: [action.color, action.color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
                    .shadow(color: action.color.opacity(0.4), radius: pressed ? 3 : 8)
            )
            .scaleEffect(pressed ? 0.95 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct WideActionButton: View {
    let action: PetAction
    let onTap: () -> Void
    @State private var pressed = false
    
    var body: some View {
        Button {
            pressed = true
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { pressed = false }
        } label: {
            HStack(spacing: 10) {
                Text(action.icon).font(.system(size: 24))
                Text(action.displayName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [action.color, action.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: action.color.opacity(0.4), radius: pressed ? 3 : 8)
            )
            .scaleEffect(pressed ? 0.98 : 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Overlays

struct LevelUpOverlay: View {
    @State private var scale: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("⭐").font(.system(size: 80))
                Text("Niveau supérieur !").font(.title.bold()).foregroundColor(.white)
            }
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { scale = 1 }
        }
    }
}

struct EvolutionOverlay: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var show = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            if let pet = viewModel.pet {
                VStack(spacing: 30) {
                    Text("✨ ÉVOLUTION ✨").font(.title.bold()).foregroundColor(.yellow)
                    if show {
                        PetAvatarView(
                            petType: pet.type,
                            mood: .happy,
                            size: 200 * pet.evolutionStage.sizeMultiplier,
                            animation: .celebrate
                        )
                    }
                    Text("\(pet.name) est maintenant \(pet.evolutionStage.rawValue) !")
                        .font(.headline).foregroundColor(.white)
                    Text(pet.evolutionStage.emoji).font(.system(size: 50))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring()) { show = true }
            }
        }
    }
}
