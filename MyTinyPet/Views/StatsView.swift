//
//  StatsView.swift
//  MyTinyPet
//
//  Vue affichant les statistiques du jeu
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header avec l'animal
                    if let pet = viewModel.pet {
                        VStack(spacing: 15) {
                            PetAvatarView(petType: pet.type, mood: pet.currentMood, size: 100)
                            
                            Text(pet.name)
                                .font(.title.bold())
                            
                            // Score de bonheur
                            HappinessScoreView(score: pet.happinessScore)
                        }
                        .padding(.top, 20)
                    }
                    
                    // Statistiques principales
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        StatCard(
                            title: "Jours ensemble",
                            value: "\(viewModel.pet?.daysSinceCreation ?? 0)",
                            icon: "calendar",
                            color: .purple
                        )
                        
                        StatCard(
                            title: "Actions totales",
                            value: "\(viewModel.totalActionsPerformed)",
                            icon: "hand.tap.fill",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Repas donnés",
                            value: "\(viewModel.totalFeedActions)",
                            icon: "fork.knife",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Verres d'eau",
                            value: "\(viewModel.totalDrinkActions)",
                            icon: "drop.fill",
                            color: .cyan
                        )
                        
                        StatCard(
                            title: "Câlins",
                            value: "\(viewModel.totalPetActions)",
                            icon: "heart.fill",
                            color: .pink
                        )
                        
                        StatCard(
                            title: "Bonheur moyen",
                            value: "\(Int(viewModel.pet?.happinessScore ?? 0))%",
                            icon: "face.smiling.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Jauges actuelles
                    if let pet = viewModel.pet {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("État actuel")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                DetailedStatBar(
                                    label: "Satiété",
                                    value: pet.hunger,
                                    icon: "🍎",
                                    color: .orange
                                )
                                
                                DetailedStatBar(
                                    label: "Hydratation",
                                    value: pet.thirst,
                                    icon: "💧",
                                    color: .blue
                                )
                                
                                DetailedStatBar(
                                    label: "Affection",
                                    value: pet.affection,
                                    icon: "❤️",
                                    color: .pink
                                )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: .black.opacity(0.1), radius: 5)
                            )
                            .padding(.horizontal)
                        }
                    }
                    
                    // Infos sur la date de création
                    if let pet = viewModel.pet {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.gray)
                            Text("Adopté le \(pet.creationDate.formatted(date: .long, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer(minLength: 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Statistiques")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Composants

struct HappinessScoreView: View {
    let score: Double
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: score / 100)
                    .stroke(
                        scoreColor,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(score))")
                    .font(.title2.bold())
                    .foregroundColor(scoreColor)
            }
            
            Text("Bonheur")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var scoreColor: Color {
        if score >= 70 { return .green }
        if score >= 40 { return .orange }
        return .red
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5)
        )
    }
}

struct DetailedStatBar: View {
    let label: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(label)
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text("\(Int(value))%")
                        .font(.subheadline.bold())
                        .foregroundColor(value < 30 ? .red : .primary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.gray.opacity(0.2))
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [color.opacity(0.6), color],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, geometry.size.width * CGFloat(value / 100)))
                    }
                }
                .frame(height: 12)
            }
        }
    }
}

#Preview {
    StatsView()
        .environmentObject({
            let vm = GameViewModel()
            vm.createPet(type: .frog, name: "Grenouillette")
            vm.totalActionsPerformed = 42
            vm.totalFeedActions = 15
            vm.totalDrinkActions = 12
            vm.totalPetActions = 15
            return vm
        }())
}
