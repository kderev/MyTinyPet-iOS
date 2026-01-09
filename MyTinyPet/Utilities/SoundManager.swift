//
//  SoundManager.swift
//  MyTinyPet
//

import Foundation
import UIKit
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private init() {}
    
    func playHaptic(for animation: PetAnimation) {
        let generator: UIImpactFeedbackGenerator
        
        switch animation {
        case .eating, .drinking:
            generator = UIImpactFeedbackGenerator(style: .medium)
        case .loved, .celebrate, .evolving:
            generator = UIImpactFeedbackGenerator(style: .heavy)
        case .walking, .playing:
            generator = UIImpactFeedbackGenerator(style: .light)
        case .sad, .idle:
            return
        }
        
        generator.impactOccurred()
    }
    
    func playNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}
