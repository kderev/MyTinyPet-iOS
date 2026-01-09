//
//  MiniGameView.swift
//  MyTinyPet
//

import SwiftUI

struct MiniGameView: View {
    @EnvironmentObject var viewModel: GameViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if let pet = viewModel.pet {
            switch pet.type {
            case .frog: MosquitoGame(onComplete: finish, onQuit: quit)
            case .dog: BallGame(onComplete: finish, onQuit: quit)
            case .pig: TruffleGame(onComplete: finish, onQuit: quit)
            }
        }
    }
    
    func finish(_ score: Int) {
        viewModel.completeMiniGame(score: score)
        dismiss()
    }
    
    func quit() {
        dismiss()
    }
}

// MARK: - Mosquito Game (Frog)

struct MosquitoGame: View {
    let onComplete: (Int) -> Void
    let onQuit: () -> Void
    
    @State private var score = 0
    @State private var timeRemaining = 20
    @State private var targets: [GameTarget] = []
    @State private var gameStarted = false
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(colors: [Color(hex: "2E4A3E"), Color(hex: "1A3A2A")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Lily pads decoration
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .fill(Color(hex: "228B22").opacity(0.3))
                    .frame(width: CGFloat.random(in: 60...100))
                    .position(x: CGFloat(50 + i * 70), y: CGFloat.random(in: 300...600))
            }
            
            if !gameStarted {
                StartScreen(
                    emoji: "🦟",
                    title: "Chasse aux moustiques",
                    subtitle: "Tape sur les moustiques avant qu'ils s'envolent !",
                    color: .green,
                    onStart: startGame,
                    onQuit: onQuit
                )
            } else {
                // Game area
                ForEach(targets.filter { $0.active }) { target in
                    MosquitoView()
                        .position(x: target.x, y: target.y)
                        .onTapGesture { hitTarget(target) }
                        .transition(.scale)
                }
                
                // HUD
                GameHUD(score: score, time: timeRemaining, onQuit: endGame)
            }
        }
        .onDisappear {
            stopTimers()
        }
    }
    
    func startGame() {
        gameStarted = true
        timeRemaining = 20
        score = 0
        targets = []
        
        // Game timer - every second
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                timeRemaining -= 1
                if timeRemaining <= 0 {
                    endGame()
                }
            }
        }
        
        // Spawn timer
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { _ in
            DispatchQueue.main.async {
                spawnTarget()
            }
        }
        
        // Initial spawn
        spawnTarget()
    }
    
    func spawnTarget() {
        let target = GameTarget(
            x: CGFloat.random(in: 50...340),
            y: CGFloat.random(in: 150...650)
        )
        targets.append(target)
        
        // Auto-remove after 2 seconds
        let targetId = target.id
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let index = targets.firstIndex(where: { $0.id == targetId }) {
                targets[index].active = false
            }
        }
    }
    
    func hitTarget(_ target: GameTarget) {
        if let index = targets.firstIndex(where: { $0.id == target.id }), targets[index].active {
            withAnimation(.easeOut(duration: 0.2)) {
                targets[index].active = false
            }
            score += 10
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
    
    func endGame() {
        stopTimers()
        onComplete(score)
    }
    
    func stopTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
}

struct MosquitoView: View {
    @State private var wingFlap = false
    
    var body: some View {
        ZStack {
            // Body
            Ellipse()
                .fill(Color.black)
                .frame(width: 20, height: 35)
            
            // Wings
            HStack(spacing: 18) {
                Ellipse()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 28, height: 18)
                    .rotationEffect(.degrees(wingFlap ? -25 : 25))
                Ellipse()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 28, height: 18)
                    .rotationEffect(.degrees(wingFlap ? 25 : -25))
            }
            
            // Legs
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 1, height: 10)
                    }
                }
            }
            .frame(height: 45)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.08).repeatForever(autoreverses: true)) {
                wingFlap = true
            }
        }
    }
}

// MARK: - Ball Game (Dog)

struct BallGame: View {
    let onComplete: (Int) -> Void
    let onQuit: () -> Void
    
    @State private var score = 0
    @State private var timeRemaining = 20
    @State private var balls: [FallingBall] = []
    @State private var gameStarted = false
    @State private var gameTimer: Timer?
    @State private var spawnTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background - park
            LinearGradient(colors: [Color(hex: "87CEEB"), Color(hex: "90EE90")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Clouds
            ForEach(0..<3, id: \.self) { i in
                CloudShape()
                    .offset(x: CGFloat(i * 120 - 100), y: CGFloat(50 + i * 30))
            }
            
            if !gameStarted {
                StartScreen(
                    emoji: "🎾",
                    title: "Attrape la balle",
                    subtitle: "Tape sur les balles avant qu'elles touchent le sol !",
                    color: .orange,
                    onStart: startGame,
                    onQuit: onQuit
                )
            } else {
                // Balls
                ForEach(balls.filter { $0.active }) { ball in
                    BallView(color: ball.color)
                        .position(x: ball.x, y: ball.y)
                        .onTapGesture { catchBall(ball) }
                }
                
                GameHUD(score: score, time: timeRemaining, onQuit: endGame)
            }
        }
        .onDisappear {
            stopTimers()
        }
    }
    
    func startGame() {
        gameStarted = true
        timeRemaining = 20
        score = 0
        balls = []
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                timeRemaining -= 1
                if timeRemaining <= 0 {
                    endGame()
                }
            }
        }
        
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                spawnBall()
            }
        }
        
        // Initial spawn
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            spawnBall()
        }
    }
    
    func spawnBall() {
        let colors: [Color] = [.red, .yellow, .blue, .green, .orange, .purple]
        let ball = FallingBall(
            x: CGFloat.random(in: 60...330),
            startY: -30,
            color: colors.randomElement() ?? .red
        )
        balls.append(ball)
        
        let ballId = ball.id
        
        // Animate falling
        animateBall(ballId)
    }
    
    func animateBall(_ ballId: UUID) {
        // Animate over 2.5 seconds
        let duration = 2.5
        let steps = 50
        let stepDuration = duration / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                if let index = balls.firstIndex(where: { $0.id == ballId && $0.active }) {
                    let progress = Double(step) / Double(steps)
                    balls[index].y = -30 + (780 * progress)
                    
                    if step == steps {
                        balls[index].active = false
                    }
                }
            }
        }
    }
    
    func catchBall(_ ball: FallingBall) {
        if let index = balls.firstIndex(where: { $0.id == ball.id }), balls[index].active {
            balls[index].active = false
            score += 15
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
    
    func endGame() {
        stopTimers()
        onComplete(score)
    }
    
    func stopTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
}

struct FallingBall: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var active = true
    var color: Color
    
    init(x: CGFloat, startY: CGFloat, color: Color) {
        self.x = x
        self.y = startY
        self.color = color
    }
}

struct BallView: View {
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [color.opacity(0.8), color],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 30
                    )
                )
                .frame(width: 55, height: 55)
            
            // Highlight
            Circle()
                .fill(Color.white.opacity(0.4))
                .frame(width: 18, height: 18)
                .offset(x: -12, y: -12)
        }
        .shadow(color: color.opacity(0.5), radius: 5, y: 3)
    }
}

struct CloudShape: View {
    var body: some View {
        HStack(spacing: -15) {
            Circle().fill(Color.white.opacity(0.9)).frame(width: 35, height: 35)
            Circle().fill(Color.white.opacity(0.9)).frame(width: 50, height: 50)
            Circle().fill(Color.white.opacity(0.9)).frame(width: 40, height: 40)
        }
    }
}

// MARK: - Truffle Game (Pig)

struct TruffleGame: View {
    let onComplete: (Int) -> Void
    let onQuit: () -> Void
    
    @State private var score = 0
    @State private var timeRemaining = 25
    @State private var mounds: [TruffleMound] = []
    @State private var gameStarted = false
    @State private var gameTimer: Timer?
    
    var body: some View {
        ZStack {
            // Background - forest floor
            LinearGradient(colors: [Color(hex: "228B22"), Color(hex: "8B4513")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Leaves decoration
            ForEach(0..<8, id: \.self) { i in
                Text("🍂")
                    .font(.system(size: 25))
                    .position(x: CGFloat.random(in: 30...370), y: CGFloat.random(in: 100...700))
                    .opacity(0.6)
            }
            
            if !gameStarted {
                StartScreen(
                    emoji: "🍄",
                    title: "Cherche les truffes",
                    subtitle: "Tape sur les mottes de terre pour trouver les truffes cachées !",
                    color: Color(hex: "8B4513"),
                    onStart: startGame,
                    onQuit: onQuit
                )
            } else {
                // Mounds
                ForEach(mounds) { mound in
                    if mound.active {
                        DirtMoundView()
                            .position(x: mound.x, y: mound.y)
                            .onTapGesture { digMound(mound) }
                    } else if mound.revealed {
                        Text(mound.hasTruffle ? "🍄" : "💨")
                            .font(.system(size: mound.hasTruffle ? 45 : 35))
                            .position(x: mound.x, y: mound.y)
                    }
                }
                
                GameHUD(score: score, time: timeRemaining, onQuit: endGame)
            }
        }
        .onDisappear {
            stopTimers()
        }
    }
    
    func startGame() {
        gameStarted = true
        timeRemaining = 25
        score = 0
        mounds = []
        
        spawnMounds()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            DispatchQueue.main.async {
                timeRemaining -= 1
                
                // Spawn more mounds every 4 seconds
                if timeRemaining % 4 == 0 && timeRemaining > 0 {
                    spawnMounds()
                }
                
                if timeRemaining <= 0 {
                    endGame()
                }
            }
        }
    }
    
    func spawnMounds() {
        let count = Int.random(in: 4...6)
        for _ in 0..<count {
            let mound = TruffleMound(
                x: CGFloat.random(in: 60...340),
                y: CGFloat.random(in: 180...650),
                hasTruffle: Double.random(in: 0...1) < 0.4 // 40% chance
            )
            mounds.append(mound)
        }
    }
    
    func digMound(_ mound: TruffleMound) {
        if let index = mounds.firstIndex(where: { $0.id == mound.id }), mounds[index].active {
            mounds[index].active = false
            mounds[index].revealed = true
            
            if mound.hasTruffle {
                score += 20
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            } else {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            
            // Hide after delay
            let moundId = mound.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if let idx = mounds.firstIndex(where: { $0.id == moundId }) {
                    mounds[idx].revealed = false
                }
            }
        }
    }
    
    func endGame() {
        stopTimers()
        onComplete(score)
    }
    
    func stopTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}

struct TruffleMound: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var active = true
    var revealed = false
    var hasTruffle: Bool
}

struct DirtMoundView: View {
    @State private var wiggle = false
    
    var body: some View {
        ZStack {
            // Dirt mound
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "8B6914"), Color(hex: "654321")],
                        center: .top,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 75, height: 55)
            
            // Grass on top
            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hex: "32CD32"))
                        .frame(width: 5, height: CGFloat.random(in: 12...18))
                }
            }
            .offset(y: -22)
            .rotationEffect(.degrees(wiggle ? -4 : 4))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
                wiggle = true
            }
        }
    }
}

// MARK: - Shared Components

struct GameTarget: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var active = true
}

struct StartScreen: View {
    let emoji: String
    let title: String
    let subtitle: String
    let color: Color
    let onStart: () -> Void
    let onQuit: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Text(emoji)
                .font(.system(size: 100))
                .shadow(radius: 10)
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.body)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: onStart) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Jouer")
                }
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.vertical, 16)
                .padding(.horizontal, 50)
                .background(Capsule().fill(color))
                .shadow(color: color.opacity(0.5), radius: 10, y: 5)
            }
            
            Button(action: onQuit) {
                HStack {
                    Image(systemName: "xmark")
                    Text("Quitter")
                }
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
}

struct GameHUD: View {
    let score: Int
    let time: Int
    let onQuit: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                // Quit button
                Button(action: onQuit) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Score
                HStack(spacing: 6) {
                    Text("🎯")
                    Text("\(score)")
                        .font(.title2.bold())
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.white.opacity(0.95)))
                
                Spacer()
                
                // Timer
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundColor(time <= 5 ? .red : .primary)
                    Text("\(time)s")
                        .font(.title2.bold().monospacedDigit())
                        .foregroundColor(time <= 5 ? .red : .primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.white.opacity(0.95)))
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            Spacer()
        }
    }
}
