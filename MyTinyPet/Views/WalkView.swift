//
//  WalkView.swift
//  MyTinyPet
//

import SwiftUI

struct WalkView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var startTime = Date()
    @State private var elapsed: TimeInterval = 0
    @State private var poopCount = 0
    @State private var petPos = CGPoint(x: 0.5, y: 0.7)
    @State private var isWalking = false
    
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: "87CEEB"), Color(hex: "98FB98")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Sol
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color(hex: "8B4513").opacity(0.3))
                    .frame(height: 150)
            }
            .ignoresSafeArea()
            
            // Animal
            GeometryReader { geo in
                if let pet = viewModel.pet {
                    PetAvatarView(
                        petType: pet.type,
                        mood: .happy,
                        size: 100 * pet.evolutionStage.sizeMultiplier,
                        animation: isWalking ? .walking : .idle
                    )
                    .position(x: geo.size.width * petPos.x, y: geo.size.height * petPos.y)
                    .gesture(
                        DragGesture()
                            .onChanged { v in
                                withAnimation(.easeOut(duration: 0.1)) {
                                    petPos = CGPoint(
                                        x: v.location.x / geo.size.width,
                                        y: min(0.85, max(0.3, v.location.y / geo.size.height))
                                    )
                                    isWalking = true
                                }
                            }
                            .onEnded { _ in isWalking = false }
                    )
                    .onTapGesture(count: 2) {
                        if let p = viewModel.pet, p.bladder < 80 {
                            poopCount += 1
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                }
            }
            
            // UI
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("🌳 Promenade").font(.title2.bold())
                        Text(timeString).font(.title3.monospacedDigit()).foregroundColor(.secondary)
                    }
                    Spacer()
                    HStack {
                        Text("💩")
                        Text("\(poopCount)").font(.title2.bold())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.white.opacity(0.9)))
                }
                .padding()
                .background(.ultraThinMaterial)
                
                Spacer()
                
                if poopCount == 0 && elapsed < 5 {
                    Text("👆 Glisse pour promener • Double-tap pour les besoins")
                        .font(.caption)
                        .padding(8)
                        .background(Capsule().fill(.white.opacity(0.8)))
                }
                
                Spacer()
                
                Button {
                    viewModel.completeWalk(duration: elapsed, poopCount: poopCount)
                    dismiss()
                } label: {
                    HStack {
                        Image(systemName: "house.fill")
                        Text("Rentrer")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(RoundedRectangle(cornerRadius: 15).fill(.green))
                }
                .padding()
            }
        }
        .onAppear { startTime = Date() }
        .onReceive(timer) { _ in elapsed = Date().timeIntervalSince(startTime) }
    }
    
    var timeString: String {
        String(format: "%02d:%02d", Int(elapsed) / 60, Int(elapsed) % 60)
    }
}
