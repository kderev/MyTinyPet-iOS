//
//  OnboardingView.swift
//  MyTinyPet
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @State private var selectedType: PetType = .pig
    @State private var petName: String = ""
    @State private var animateSelection = false
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    selectedType.primaryColor.opacity(0.3),
                    Color(hex: "FFF8E1"),
                    selectedType.secondaryColor.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: selectedType)
            
            // Decorative circles
            Circle()
                .fill(selectedType.primaryColor.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -100, y: -200)
            
            Circle()
                .fill(selectedType.secondaryColor.opacity(0.15))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: 150, y: 300)
            
            VStack(spacing: 0) {
                // Scrollable content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Text("🐾")
                                .font(.system(size: 40))
                            
                            Text("MyTinyPet")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [selectedType.primaryColor, selectedType.secondaryColor],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Adopte ton compagnon")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Animal Preview
                        ZStack {
                            Circle()
                                .fill(selectedType.primaryColor.opacity(0.2))
                                .frame(width: 160, height: 160)
                                .blur(radius: 15)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white, selectedType.primaryColor.opacity(0.2)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 150, height: 150)
                                .shadow(color: selectedType.primaryColor.opacity(0.3), radius: 15)
                            
                            PetAvatarView(
                                petType: selectedType,
                                mood: .happy,
                                size: 110,
                                animation: animateSelection ? .celebrate : .idle
                            )
                        }
                        
                        // Animal selection cards
                        VStack(spacing: 12) {
                            Text("Choisis ton animal")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
                                ForEach(PetType.allCases) { type in
                                    AnimalSelectionCard(
                                        type: type,
                                        isSelected: selectedType == type
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            selectedType = type
                                            animateSelection = true
                                        }
                                        
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            animateSelection = false
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Name input
                        VStack(spacing: 10) {
                            Text("Comment s'appelle-t-il ?")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(selectedType.primaryColor)
                                
                                TextField("Donne-lui un nom...", text: $petName)
                                    .font(.system(size: 17, design: .rounded))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.08), radius: 8)
                            )
                            .padding(.horizontal, 25)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // FIXED BOTTOM: Adopt button (always visible)
                VStack(spacing: 12) {
                    Button {
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        viewModel.createPet(type: selectedType, name: petName)
                    } label: {
                        HStack(spacing: 12) {
                            Text("Adopter \(selectedType.displayName)")
                                .font(.title3.bold())
                            
                            Image(systemName: "heart.fill")
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [selectedType.primaryColor, selectedType.secondaryColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: selectedType.primaryColor.opacity(0.5), radius: 12, y: 6)
                    }
                    .padding(.horizontal, 30)
                    
                    Text("🍎 Nourris-le  •  💧 Hydrate-le  •  ❤️ Aime-le")
                        .font(.caption)
                        .foregroundColor(.secondary.opacity(0.8))
                }
                .padding(.vertical, 15)
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea(edges: .bottom)
                )
            }
        }
    }
}

// MARK: - Animal Selection Card

struct AnimalSelectionCard: View {
    let type: PetType
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        isSelected ?
                        LinearGradient(colors: [type.primaryColor.opacity(0.3), type.primaryColor.opacity(0.1)], startPoint: .top, endPoint: .bottom) :
                        LinearGradient(colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)], startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 70, height: 70)
                
                PetAvatarView(
                    petType: type,
                    mood: isSelected ? .happy : .neutral,
                    size: 50,
                    animation: .idle
                )
            }
            
            Text(type.displayName)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? type.secondaryColor : .gray)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? Color.white : Color.white.opacity(0.6))
                .shadow(
                    color: isSelected ? type.primaryColor.opacity(0.3) : .clear,
                    radius: 8
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    isSelected ? type.primaryColor : Color.clear,
                    lineWidth: 2.5
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}
