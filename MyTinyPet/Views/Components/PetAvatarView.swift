//
//  PetAvatarView.swift
//  MyTinyPet
//

import SwiftUI

struct PetAvatarView: View {
    let petType: PetType
    let mood: PetMood
    var size: CGFloat = 100
    var animation: PetAnimation = .idle
    
    var body: some View {
        switch petType {
        case .pig: PigView(mood: mood, size: size, animation: animation)
        case .dog: DogView(mood: mood, size: size, animation: animation)
        case .frog: FrogView(mood: mood, size: size, animation: animation)
        }
    }
}

// MARK: - Pig

struct PigView: View {
    let mood: PetMood
    let size: CGFloat
    let animation: PetAnimation
    
    @State private var bounce: CGFloat = 0
    @State private var tilt: Double = 0
    @State private var eyesClosed = false
    @State private var mouthOpen = false
    @State private var blush = false
    @State private var showHearts = false
    
    var body: some View {
        ZStack {
            if showHearts { Hearts(size: size) }
            
            ZStack {
                // Head
                Circle()
                    .fill(RadialGradient(colors: [Color(hex: "FFC0CB"), Color(hex: "FFB6C1")], center: .topLeading, startRadius: 0, endRadius: size))
                    .frame(width: size, height: size)
                
                // Ears
                HStack(spacing: size * 0.5) {
                    Ear(size: size, color: Color(hex: "FFB6C1"))
                    Ear(size: size, color: Color(hex: "FFB6C1"))
                }
                .offset(y: -size * 0.35)
                
                // Face
                VStack(spacing: size * 0.03) {
                    // Eyes
                    HStack(spacing: size * 0.22) {
                        Eye(size: size * 0.18, closed: eyesClosed || mood == .happy || mood == .loving)
                        Eye(size: size * 0.18, closed: eyesClosed || mood == .happy || mood == .loving)
                    }
                    
                    // Snout
                    ZStack {
                        Ellipse().fill(Color(hex: "FF69B4"))
                            .frame(width: size * 0.4, height: size * 0.28)
                        HStack(spacing: size * 0.1) {
                            Ellipse().fill(Color(hex: "DB7093")).frame(width: size * 0.07, height: size * 0.09)
                            Ellipse().fill(Color(hex: "DB7093")).frame(width: size * 0.07, height: size * 0.09)
                        }
                        .offset(y: -size * 0.02)
                    }
                    
                    // Mouth
                    if mouthOpen {
                        Ellipse().fill(Color(hex: "8B4513")).frame(width: size * 0.12, height: size * 0.1)
                    } else if mood == .happy || mood == .loving {
                        SmilePath(size: size)
                    }
                }
                .offset(y: size * 0.08)
                
                // Blush
                if blush || mood == .loving {
                    HStack(spacing: size * 0.5) {
                        Circle().fill(Color.red.opacity(0.35)).frame(width: size * 0.15)
                        Circle().fill(Color.red.opacity(0.35)).frame(width: size * 0.15)
                    }
                    .offset(y: size * 0.1)
                }
            }
            .rotationEffect(.degrees(tilt))
            .offset(y: bounce)
        }
        .onChange(of: animation) { _, anim in trigger(anim) }
        .onAppear { if animation != .idle { trigger(animation) } }
    }
    
    func trigger(_ anim: PetAnimation) {
        reset()
        switch anim {
        case .eating: animateEating()
        case .drinking: animateDrinking()
        case .loved: animateLoved()
        case .celebrate, .evolving: animateCelebrate()
        case .walking, .playing: animateWalking()
        default: break
        }
    }
    
    func reset() {
        withAnimation(.easeOut(duration: 0.15)) {
            bounce = 0; tilt = 0; eyesClosed = false; mouthOpen = false; blush = false; showHearts = false
        }
    }
    
    func animateEating() {
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                withAnimation(.easeInOut(duration: 0.09)) {
                    mouthOpen.toggle()
                    bounce = mouthOpen ? -5 : 0
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { withAnimation { eyesClosed = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateDrinking() {
        withAnimation(.easeInOut(duration: 0.3)) { tilt = 15; mouthOpen = true }
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3 + Double(i) * 0.22) {
                withAnimation(.easeInOut(duration: 0.11)) { bounce = -6 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                    withAnimation { bounce = 0 }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateLoved() {
        showHearts = true
        withAnimation(.easeInOut(duration: 0.2)) { eyesClosed = true; blush = true }
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                withAnimation(.easeInOut(duration: 0.09)) {
                    tilt = i % 2 == 0 ? 10 : -10
                    bounce = -10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                    withAnimation { bounce = 0 }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateCelebrate() {
        showHearts = true; blush = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { bounce = -25 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { withAnimation(.spring()) { bounce = 0 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { reset() }
    }
    
    func animateWalking() {
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                withAnimation(.easeInOut(duration: 0.075)) {
                    bounce = -8
                    tilt = i % 2 == 0 ? 5 : -5
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.075) {
                    withAnimation { bounce = 0 }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
}

// MARK: - Dog

struct DogView: View {
    let mood: PetMood
    let size: CGFloat
    let animation: PetAnimation
    
    @State private var bounce: CGFloat = 0
    @State private var tilt: Double = 0
    @State private var eyesClosed = false
    @State private var tongueOut = false
    @State private var showHearts = false
    
    var body: some View {
        ZStack {
            if showHearts { Hearts(size: size) }
            
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Color(hex: "E8D4B8"), Color(hex: "DEB887")], center: .topLeading, startRadius: 0, endRadius: size))
                    .frame(width: size, height: size)
                
                // Ears
                HStack(spacing: size * 0.65) {
                    Ellipse().fill(Color(hex: "8B4513")).frame(width: size * 0.25, height: size * 0.4)
                    Ellipse().fill(Color(hex: "8B4513")).frame(width: size * 0.25, height: size * 0.4)
                }
                .offset(y: -size * 0.12)
                
                // Eye patch
                Circle().fill(Color(hex: "8B4513")).frame(width: size * 0.28).offset(x: -size * 0.15, y: -size * 0.12)
                
                // Face
                VStack(spacing: size * 0.02) {
                    HStack(spacing: size * 0.22) {
                        Eye(size: size * 0.16, closed: eyesClosed || mood == .happy || mood == .loving)
                        Eye(size: size * 0.16, closed: eyesClosed || mood == .happy || mood == .loving)
                    }
                    
                    ZStack {
                        Ellipse().fill(Color(hex: "F5E6D3")).frame(width: size * 0.38, height: size * 0.3)
                        Ellipse().fill(Color(hex: "2F1810")).frame(width: size * 0.14, height: size * 0.1).offset(y: -size * 0.04)
                        
                        if tongueOut || mood == .happy {
                            RoundedRectangle(cornerRadius: 4).fill(Color(hex: "FF6B6B"))
                                .frame(width: size * 0.07, height: size * 0.1)
                                .offset(y: size * 0.1)
                        }
                    }
                    .offset(y: size * 0.03)
                }
            }
            .rotationEffect(.degrees(tilt))
            .offset(y: bounce)
        }
        .onChange(of: animation) { _, anim in trigger(anim) }
        .onAppear { if animation != .idle { trigger(animation) } }
    }
    
    func trigger(_ anim: PetAnimation) {
        reset()
        switch anim {
        case .eating: animateEating()
        case .drinking: animateDrinking()
        case .loved: animateLoved()
        case .celebrate, .evolving: animateCelebrate()
        case .walking, .playing: animateWalking()
        default: break
        }
    }
    
    func reset() {
        withAnimation(.easeOut(duration: 0.15)) {
            bounce = 0; tilt = 0; eyesClosed = false; tongueOut = false; showHearts = false
        }
    }
    
    func animateEating() {
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.16) {
                withAnimation(.easeInOut(duration: 0.08)) { bounce = i % 2 == 0 ? -5 : 0 }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { withAnimation { eyesClosed = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { tongueOut = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { reset() }
    }
    
    func animateDrinking() {
        tongueOut = true
        withAnimation(.easeInOut(duration: 0.25)) { tilt = 18 }
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 + Double(i) * 0.18) {
                withAnimation(.easeInOut(duration: 0.09)) { bounce = -4 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) { withAnimation { bounce = 0 } }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateLoved() {
        showHearts = true; tongueOut = true
        withAnimation(.easeInOut(duration: 0.2)) { eyesClosed = true }
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.14) {
                withAnimation(.easeInOut(duration: 0.07)) {
                    tilt = i % 2 == 0 ? 12 : -12
                    bounce = -8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) { withAnimation { bounce = 0 } }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateCelebrate() {
        showHearts = true; tongueOut = true
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { bounce = -28 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { withAnimation(.spring()) { bounce = 0 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { reset() }
    }
    
    func animateWalking() {
        tongueOut = true
        for i in 0..<8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.12) {
                withAnimation(.easeInOut(duration: 0.06)) {
                    bounce = -6
                    tilt = i % 2 == 0 ? 8 : -8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { withAnimation { bounce = 0 } }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { reset() }
    }
}

// MARK: - Frog

struct FrogView: View {
    let mood: PetMood
    let size: CGFloat
    let animation: PetAnimation
    
    @State private var bounce: CGFloat = 0
    @State private var tilt: Double = 0
    @State private var eyesClosed = false
    @State private var puffed = false
    @State private var showHearts = false
    
    var body: some View {
        ZStack {
            if showHearts { Hearts(size: size) }
            
            ZStack {
                Ellipse()
                    .fill(RadialGradient(colors: [Color(hex: "98FB98"), Color(hex: "90EE90")], center: .topLeading, startRadius: 0, endRadius: size))
                    .frame(width: size, height: size * 0.9)
                
                // Spots
                Circle().fill(Color(hex: "228B22").opacity(0.4)).frame(width: size * 0.15).offset(x: -size * 0.25, y: size * 0.1)
                Circle().fill(Color(hex: "228B22").opacity(0.4)).frame(width: size * 0.1).offset(x: size * 0.28, y: -size * 0.05)
                
                // Eyes
                HStack(spacing: size * 0.2) {
                    FrogEye(size: size * 0.32, closed: eyesClosed || mood == .loving)
                    FrogEye(size: size * 0.32, closed: eyesClosed || mood == .loving)
                }
                .offset(y: -size * 0.38)
                
                // Cheeks
                if puffed || mood == .happy {
                    HStack(spacing: size * 0.55) {
                        Circle().fill(Color(hex: "B8F5B8")).frame(width: size * 0.18)
                        Circle().fill(Color(hex: "B8F5B8")).frame(width: size * 0.18)
                    }
                    .offset(y: size * 0.05)
                }
                
                // Mouth
                if mood == .happy || mood == .loving {
                    SmilePath(size: size * 1.5).offset(y: size * 0.15)
                }
            }
            .rotationEffect(.degrees(tilt))
            .offset(y: bounce)
        }
        .onChange(of: animation) { _, anim in trigger(anim) }
        .onAppear { if animation != .idle { trigger(animation) } }
    }
    
    func trigger(_ anim: PetAnimation) {
        reset()
        switch anim {
        case .eating: animateEating()
        case .drinking: animateDrinking()
        case .loved: animateLoved()
        case .celebrate, .evolving: animateCelebrate()
        case .walking, .playing: animateHopping()
        default: break
        }
    }
    
    func reset() {
        withAnimation(.easeOut(duration: 0.15)) {
            bounce = 0; tilt = 0; eyesClosed = false; puffed = false; showHearts = false
        }
    }
    
    func animateEating() {
        for i in 0..<4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35 + Double(i) * 0.18) {
                withAnimation(.easeInOut(duration: 0.09)) {
                    puffed.toggle()
                    bounce = puffed ? -4 : 0
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { withAnimation { eyesClosed = true } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateDrinking() {
        withAnimation(.easeInOut(duration: 0.25)) { tilt = 12 }
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25 + Double(i) * 0.18) {
                withAnimation(.easeInOut(duration: 0.09)) {
                    puffed.toggle()
                    bounce = puffed ? -3 : 0
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateLoved() {
        showHearts = true
        withAnimation(.easeInOut(duration: 0.2)) { eyesClosed = true; puffed = true }
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                withAnimation(.spring(response: 0.12, dampingFraction: 0.5)) { bounce = -15 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { withAnimation(.spring()) { bounce = 0 } }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
    
    func animateCelebrate() {
        showHearts = true; puffed = true
        withAnimation(.spring(response: 0.25, dampingFraction: 0.4)) { bounce = -35 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { withAnimation(.spring()) { bounce = 0 } }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { reset() }
    }
    
    func animateHopping() {
        for i in 0..<6 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                    bounce = -20
                    puffed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring()) { bounce = 0; puffed = false }
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { reset() }
    }
}

// MARK: - Shared Components

struct Eye: View {
    let size: CGFloat
    let closed: Bool
    
    var body: some View {
        ZStack {
            if closed {
                Path { p in
                    p.move(to: CGPoint(x: 0, y: size * 0.6))
                    p.addQuadCurve(to: CGPoint(x: size, y: size * 0.6), control: CGPoint(x: size * 0.5, y: 0))
                }
                .stroke(Color(hex: "4A4A4A"), lineWidth: 2.5)
                .frame(width: size, height: size)
            } else {
                Circle().fill(Color.white).frame(width: size, height: size)
                Circle().fill(Color(hex: "4A4A4A")).frame(width: size * 0.5, height: size * 0.5)
                Circle().fill(Color.white).frame(width: size * 0.18, height: size * 0.18).offset(x: -size * 0.08, y: -size * 0.08)
            }
        }
    }
}

struct FrogEye: View {
    let size: CGFloat
    let closed: Bool
    
    var body: some View {
        ZStack {
            Circle().fill(Color.white).frame(width: size, height: size)
            if closed {
                Path { p in
                    p.move(to: CGPoint(x: 0, y: size * 0.5))
                    p.addQuadCurve(to: CGPoint(x: size * 0.7, y: size * 0.5), control: CGPoint(x: size * 0.35, y: size * 0.2))
                }
                .stroke(Color(hex: "228B22"), lineWidth: 2.5)
                .frame(width: size * 0.7, height: size * 0.5)
            } else {
                Circle().fill(Color(hex: "FFD700")).frame(width: size * 0.65)
                Capsule().fill(Color.black).frame(width: size * 0.12, height: size * 0.4)
                Circle().fill(Color.white.opacity(0.8)).frame(width: size * 0.12).offset(x: -size * 0.12, y: -size * 0.12)
            }
        }
    }
}

struct Ear: View {
    let size: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Ellipse().fill(color).frame(width: size * 0.22, height: size * 0.28)
            Ellipse().fill(Color(hex: "FF69B4").opacity(0.5)).frame(width: size * 0.12, height: size * 0.16)
        }
    }
}

struct SmilePath: View {
    let size: CGFloat
    
    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: 0, y: 0))
            p.addQuadCurve(to: CGPoint(x: size * 0.18, y: 0), control: CGPoint(x: size * 0.09, y: size * 0.1))
        }
        .stroke(Color(hex: "8B4513"), lineWidth: 2.5)
        .frame(width: size * 0.18, height: size * 0.1)
    }
}

struct Hearts: View {
    let size: CGFloat
    @State private var hearts: [(id: UUID, x: CGFloat, y: CGFloat, opacity: Double)] = []
    
    var body: some View {
        ZStack {
            ForEach(hearts, id: \.id) { h in
                Text("❤️").font(.system(size: 20)).offset(x: h.x, y: h.y).opacity(h.opacity)
            }
        }
        .onAppear {
            for i in 0..<6 {
                let h = (id: UUID(), x: CGFloat.random(in: -size*0.5...size*0.5), y: -size*0.2, opacity: 1.0)
                hearts.append(h)
                withAnimation(.easeOut(duration: 1.0).delay(Double(i) * 0.1)) {
                    if let idx = hearts.firstIndex(where: { $0.id == h.id }) {
                        hearts[idx].y = -size * 0.7
                        hearts[idx].opacity = 0
                    }
                }
            }
        }
    }
}
