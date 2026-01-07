//
//  PetAvatarView.swift
//  MyTinyPet
//
//  Composant visuel pour afficher l'animal avec différentes expressions
//

import SwiftUI

struct PetAvatarView: View {
    let petType: PetType
    let mood: PetMood
    var size: CGFloat = 100
    var animation: PetAnimation = .idle
    
    @State private var animationOffset: CGFloat = 0
    @State private var animationScale: CGFloat = 1.0
    @State private var showParticles: Bool = false
    
    var body: some View {
        ZStack {
            // Particules d'animation
            if showParticles {
                ParticlesView(animation: animation, petType: petType)
            }
            
            // L'animal selon son type
            Group {
                switch petType {
                case .pig:
                    PigView(mood: mood, size: size)
                case .dog:
                    DogView(mood: mood, size: size)
                case .frog:
                    FrogView(mood: mood, size: size)
                }
            }
            .scaleEffect(animationScale)
            .offset(y: animationOffset)
        }
        .onChange(of: animation) { _, newAnimation in
            triggerAnimation(newAnimation)
        }
    }
    
    private func triggerAnimation(_ anim: PetAnimation) {
        showParticles = false
        
        switch anim {
        case .eating, .drinking:
            // Animation de rebond
            withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                animationScale = 1.15
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    animationScale = 1.0
                }
            }
            showParticles = true
            
        case .loved:
            // Animation de cœurs
            withAnimation(.easeInOut(duration: 0.3)) {
                animationOffset = -10
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring()) {
                    animationOffset = 0
                }
            }
            showParticles = true
            
        case .celebrate:
            // Animation de célébration
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                animationScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring()) {
                    animationScale = 1.0
                }
            }
            showParticles = true
            
        case .sad:
            withAnimation(.easeInOut(duration: 0.5)) {
                animationOffset = 5
            }
            
        case .idle:
            withAnimation(.spring()) {
                animationOffset = 0
                animationScale = 1.0
            }
            showParticles = false
        }
    }
}

// MARK: - Vue du Cochon

struct PigView: View {
    let mood: PetMood
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Corps principal (cercle rose)
            Circle()
                .fill(Color(hex: "FFB6C1"))
                .frame(width: size, height: size)
            
            // Oreilles
            HStack(spacing: size * 0.5) {
                PigEar()
                    .frame(width: size * 0.25, height: size * 0.3)
                    .rotationEffect(.degrees(-20))
                PigEar()
                    .frame(width: size * 0.25, height: size * 0.3)
                    .rotationEffect(.degrees(20))
            }
            .offset(y: -size * 0.35)
            
            // Visage
            VStack(spacing: size * 0.05) {
                // Yeux
                HStack(spacing: size * 0.2) {
                    EyeView(mood: mood, size: size * 0.15)
                    EyeView(mood: mood, size: size * 0.15)
                }
                
                // Museau
                ZStack {
                    Ellipse()
                        .fill(Color(hex: "FF69B4"))
                        .frame(width: size * 0.4, height: size * 0.25)
                    
                    // Narines
                    HStack(spacing: size * 0.08) {
                        Ellipse()
                            .fill(Color(hex: "DB7093"))
                            .frame(width: size * 0.08, height: size * 0.1)
                        Ellipse()
                            .fill(Color(hex: "DB7093"))
                            .frame(width: size * 0.08, height: size * 0.1)
                    }
                }
                
                // Bouche
                MouthView(mood: mood, size: size * 0.2)
            }
            .offset(y: size * 0.05)
            
            // Joues roses (quand content)
            if mood == .happy || mood == .loving {
                HStack(spacing: size * 0.55) {
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: size * 0.12, height: size * 0.12)
                    Circle()
                        .fill(Color.red.opacity(0.2))
                        .frame(width: size * 0.12, height: size * 0.12)
                }
                .offset(y: size * 0.1)
            }
        }
    }
}

struct PigEar: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(hex: "FFB6C1"))
            Ellipse()
                .fill(Color(hex: "FF69B4"))
                .scaleEffect(0.6)
        }
    }
}

// MARK: - Vue du Chien

struct DogView: View {
    let mood: PetMood
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Corps principal
            Circle()
                .fill(Color(hex: "DEB887"))
                .frame(width: size, height: size)
            
            // Oreilles tombantes
            HStack(spacing: size * 0.7) {
                DogEar()
                    .frame(width: size * 0.3, height: size * 0.45)
                    .rotationEffect(.degrees(-10))
                DogEar()
                    .frame(width: size * 0.3, height: size * 0.45)
                    .rotationEffect(.degrees(10))
            }
            .offset(y: -size * 0.15)
            
            // Tache sur l'œil
            Circle()
                .fill(Color(hex: "8B4513"))
                .frame(width: size * 0.25, height: size * 0.25)
                .offset(x: -size * 0.15, y: -size * 0.1)
            
            // Visage
            VStack(spacing: size * 0.03) {
                // Yeux
                HStack(spacing: size * 0.2) {
                    EyeView(mood: mood, size: size * 0.15)
                    EyeView(mood: mood, size: size * 0.15)
                }
                
                // Museau
                ZStack {
                    // Museau blanc
                    Ellipse()
                        .fill(Color.white)
                        .frame(width: size * 0.35, height: size * 0.28)
                    
                    // Truffe
                    Ellipse()
                        .fill(Color(hex: "2F1810"))
                        .frame(width: size * 0.15, height: size * 0.1)
                        .offset(y: -size * 0.03)
                    
                    // Bouche
                    MouthView(mood: mood, size: size * 0.15)
                        .offset(y: size * 0.08)
                }
                .offset(y: size * 0.05)
            }
            
            // Langue (si content)
            if mood == .happy || mood == .loving {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(hex: "FF6B6B"))
                    .frame(width: size * 0.08, height: size * 0.12)
                    .offset(y: size * 0.28)
            }
        }
    }
}

struct DogEar: View {
    var body: some View {
        Ellipse()
            .fill(Color(hex: "8B4513"))
    }
}

// MARK: - Vue de la Grenouille

struct FrogView: View {
    let mood: PetMood
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Corps principal
            Ellipse()
                .fill(Color(hex: "90EE90"))
                .frame(width: size, height: size * 0.9)
            
            // Yeux globuleux
            HStack(spacing: size * 0.25) {
                FrogEye(mood: mood, size: size * 0.3)
                FrogEye(mood: mood, size: size * 0.3)
            }
            .offset(y: -size * 0.35)
            
            // Taches sur le corps
            Circle()
                .fill(Color(hex: "228B22").opacity(0.5))
                .frame(width: size * 0.15, height: size * 0.15)
                .offset(x: -size * 0.2, y: size * 0.1)
            
            Circle()
                .fill(Color(hex: "228B22").opacity(0.5))
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: size * 0.25, y: -size * 0.05)
            
            // Visage
            VStack(spacing: size * 0.02) {
                // Narines
                HStack(spacing: size * 0.15) {
                    Circle()
                        .fill(Color(hex: "228B22"))
                        .frame(width: size * 0.05, height: size * 0.05)
                    Circle()
                        .fill(Color(hex: "228B22"))
                        .frame(width: size * 0.05, height: size * 0.05)
                }
                
                // Grande bouche
                FrogMouth(mood: mood, width: size * 0.5, height: size * 0.15)
            }
            .offset(y: size * 0.1)
            
            // Joues gonflées (si content)
            if mood == .happy || mood == .loving {
                HStack(spacing: size * 0.6) {
                    Circle()
                        .fill(Color(hex: "98FB98"))
                        .frame(width: size * 0.15, height: size * 0.15)
                    Circle()
                        .fill(Color(hex: "98FB98"))
                        .frame(width: size * 0.15, height: size * 0.15)
                }
                .offset(y: size * 0.05)
            }
        }
    }
}

struct FrogEye: View {
    let mood: PetMood
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Globe oculaire
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
            
            // Iris
            Circle()
                .fill(Color(hex: "FFD700"))
                .frame(width: size * 0.6, height: size * 0.6)
            
            // Pupille
            Group {
                switch mood {
                case .happy, .loving:
                    // Pupille en forme de cœur approximatif
                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.3, height: size * 0.3)
                case .sad, .tired:
                    // Pupille tombante
                    Ellipse()
                        .fill(Color.black)
                        .frame(width: size * 0.25, height: size * 0.35)
                        .offset(y: size * 0.05)
                default:
                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.25, height: size * 0.25)
                }
            }
            
            // Reflet
            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: -size * 0.1, y: -size * 0.1)
        }
    }
}

struct FrogMouth: View {
    let mood: PetMood
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Group {
            switch mood {
            case .happy, .loving:
                // Grand sourire
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: 0),
                        control: CGPoint(x: width / 2, y: height * 2)
                    )
                }
                .stroke(Color(hex: "228B22"), lineWidth: 3)
                .frame(width: width, height: height)
                
            case .sad:
                // Bouche triste
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height),
                        control: CGPoint(x: width / 2, y: 0)
                    )
                }
                .stroke(Color(hex: "228B22"), lineWidth: 3)
                .frame(width: width, height: height)
                
            default:
                // Bouche neutre
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "228B22"))
                    .frame(width: width * 0.6, height: 3)
            }
        }
    }
}

// MARK: - Composants partagés

struct EyeView: View {
    let mood: PetMood
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Fond de l'œil
            Circle()
                .fill(Color.white)
                .frame(width: size, height: size)
            
            // Pupille selon l'humeur
            Group {
                switch mood {
                case .happy, .loving:
                    // Yeux contents (arc)
                    Path { path in
                        path.addArc(
                            center: CGPoint(x: size/2, y: size/2),
                            radius: size * 0.3,
                            startAngle: .degrees(0),
                            endAngle: .degrees(-180),
                            clockwise: true
                        )
                    }
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: size, height: size)
                    
                case .sad:
                    // Yeux tristes (larme)
                    VStack(spacing: 2) {
                        Circle()
                            .fill(Color.black)
                            .frame(width: size * 0.4, height: size * 0.4)
                        Circle()
                            .fill(Color.blue.opacity(0.5))
                            .frame(width: size * 0.15, height: size * 0.15)
                    }
                    
                case .tired:
                    // Yeux fatigués (demi-fermés)
                    Ellipse()
                        .fill(Color.black)
                        .frame(width: size * 0.5, height: size * 0.2)
                    
                default:
                    // Yeux normaux
                    Circle()
                        .fill(Color.black)
                        .frame(width: size * 0.4, height: size * 0.4)
                }
            }
            
            // Reflet (sauf yeux fermés)
            if mood != .tired {
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: size * 0.15, height: size * 0.15)
                    .offset(x: -size * 0.1, y: -size * 0.1)
            }
        }
    }
}

struct MouthView: View {
    let mood: PetMood
    let size: CGFloat
    
    var body: some View {
        Group {
            switch mood {
            case .happy, .loving:
                // Sourire
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: size, y: 0),
                        control: CGPoint(x: size / 2, y: size * 0.8)
                    )
                }
                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                .frame(width: size, height: size * 0.5)
                
            case .sad:
                // Bouche triste
                Path { path in
                    path.move(to: CGPoint(x: 0, y: size * 0.3))
                    path.addQuadCurve(
                        to: CGPoint(x: size, y: size * 0.3),
                        control: CGPoint(x: size / 2, y: 0)
                    )
                }
                .stroke(Color(hex: "8B4513"), lineWidth: 2)
                .frame(width: size, height: size * 0.5)
                
            case .hungry, .thirsty:
                // Bouche ouverte
                Ellipse()
                    .fill(Color(hex: "8B4513"))
                    .frame(width: size * 0.5, height: size * 0.4)
                
            default:
                // Bouche neutre
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "8B4513"))
                    .frame(width: size * 0.5, height: 2)
            }
        }
    }
}

// MARK: - Particules d'animation

struct ParticlesView: View {
    let animation: PetAnimation
    let petType: PetType
    
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .onAppear {
            createParticles()
        }
        .onChange(of: animation) { _, _ in
            createParticles()
        }
    }
    
    private func createParticles() {
        particles = []
        
        let emoji: String
        switch animation {
        case .eating:
            emoji = "🍎"
        case .drinking:
            emoji = "💧"
        case .loved:
            emoji = "❤️"
        case .celebrate:
            emoji = "✨"
        default:
            return
        }
        
        for i in 0..<5 {
            let particle = Particle(
                id: UUID(),
                emoji: emoji,
                x: CGFloat.random(in: -50...50),
                y: CGFloat.random(in: -80...(-20)),
                size: CGFloat.random(in: 15...25),
                opacity: 1.0
            )
            particles.append(particle)
            
            // Animation de la particule
            withAnimation(.easeOut(duration: 1.0).delay(Double(i) * 0.1)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].y -= 50
                    particles[index].opacity = 0
                }
            }
        }
        
        // Nettoyer après l'animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            particles = []
        }
    }
}

struct Particle: Identifiable {
    let id: UUID
    let emoji: String
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var opacity: Double
}

#Preview {
    VStack(spacing: 30) {
        HStack(spacing: 20) {
            PetAvatarView(petType: .pig, mood: .happy, size: 100)
            PetAvatarView(petType: .dog, mood: .happy, size: 100)
            PetAvatarView(petType: .frog, mood: .happy, size: 100)
        }
        
        HStack(spacing: 20) {
            PetAvatarView(petType: .pig, mood: .sad, size: 100)
            PetAvatarView(petType: .dog, mood: .sad, size: 100)
            PetAvatarView(petType: .frog, mood: .sad, size: 100)
        }
    }
    .padding()
}
