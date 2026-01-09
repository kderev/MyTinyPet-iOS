//
//  StatsView.swift
//  MyTinyPet
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    if let pet = viewModel.pet {
                        // Header
                        VStack(spacing: 12) {
                            PetAvatarView(petType: pet.type, mood: pet.currentMood, size: 100 * pet.evolutionStage.sizeMultiplier)
                            Text(pet.name).font(.title2.bold())
                            
                            HStack(spacing: 15) {
                                Badge(text: "Niv. \(pet.level)", icon: "star.fill", color: .yellow)
                                Badge(text: pet.evolutionStage.rawValue.capitalized, icon: nil, emoji: pet.evolutionStage.emoji, color: .purple)
                            }
                            
                            // XP
                            VStack(spacing: 4) {
                                Text("Niveau \(pet.level + 1)").font(.caption).foregroundColor(.secondary)
                                ProgressView(value: pet.levelProgress).tint(.purple)
                                Text("\(pet.xp) / \(pet.xpForNextLevel) XP").font(.caption2).foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 40)
                        }
                        .padding(.top, 20)
                        
                        // Stats Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(title: "Jours", value: "\(pet.daysSinceCreation)", icon: "calendar", color: .purple)
                            StatCard(title: "Niveau", value: "\(pet.level)", icon: "star.fill", color: .yellow)
                            StatCard(title: "Repas", value: "\(viewModel.totalFeedActions)", icon: "fork.knife", color: .orange)
                            StatCard(title: "Boissons", value: "\(viewModel.totalDrinkActions)", icon: "drop.fill", color: .cyan)
                            StatCard(title: "Câlins", value: "\(viewModel.totalPetActions)", icon: "heart.fill", color: .pink)
                            StatCard(title: "Promenades", value: "\(viewModel.totalWalkActions)", icon: "figure.walk", color: .green)
                            StatCard(title: "Parties", value: "\(pet.totalMiniGamesPlayed)", icon: "gamecontroller.fill", color: .indigo)
                            StatCard(title: "Record", value: "\(pet.highScore)", icon: "trophy.fill", color: .yellow)
                        }
                        .padding(.horizontal)
                        
                        // Bonheur
                        VStack(spacing: 10) {
                            Text("Score de bonheur").font(.headline)
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                                    .frame(width: 100, height: 100)
                                Circle()
                                    .trim(from: 0, to: pet.happinessScore / 100)
                                    .stroke(happinessColor(pet.happinessScore), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                    .frame(width: 100, height: 100)
                                    .rotationEffect(.degrees(-90))
                                Text("\(Int(pet.happinessScore))%")
                                    .font(.title2.bold())
                            }
                        }
                        .padding()
                        
                        Text("Adopté le \(pet.creationDate.formatted(date: .long, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }
    
    func happinessColor(_ score: Double) -> Color {
        if score >= 70 { return .green }
        if score >= 40 { return .orange }
        return .red
    }
}

struct Badge: View {
    let text: String
    let icon: String?
    var emoji: String? = nil
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon).foregroundColor(color)
            }
            if let emoji = emoji {
                Text(emoji)
            }
            Text(text).font(.subheadline.bold())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(color.opacity(0.2)))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.title.bold())
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}
