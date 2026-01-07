//
//  SoundManager.swift
//  MyTinyPet
//
//  Gestionnaire des effets sonores du jeu
//

import Foundation
import AVFoundation
import UIKit

/// Gestionnaire des sons et effets audio
class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    
    private init() {
        // Configurer la session audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Erreur configuration audio: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Types de sons
    
    enum SoundEffect: String {
        case eat = "eat_sound"
        case drink = "drink_sound"
        case pet = "pet_sound"
        case happy = "happy_sound"
        case sad = "sad_sound"
        case celebrate = "celebrate_sound"
        case tap = "tap_sound"
    }
    
    // MARK: - Lecture des sons
    
    /// Joue un son système (comme feedback haptique)
    func playSystemSound(for action: PetAction) {
        let systemSoundID: SystemSoundID
        
        switch action {
        case .feed:
            systemSoundID = 1057  // Tink
        case .drink:
            systemSoundID = 1104  // Drip
        case .pet:
            systemSoundID = 1001  // Soft
        }
        
        AudioServicesPlaySystemSound(systemSoundID)
    }
    
    /// Joue un feedback haptique
    func playHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Joue un feedback de succès
    func playSuccessFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }
    
    /// Joue un feedback d'erreur
    func playErrorFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
    
    /// Joue un son personnalisé depuis les ressources
    func playSound(_ sound: SoundEffect) {
        guard let url = Bundle.main.url(
            forResource: sound.rawValue,
            withExtension: "mp3"
        ) else {
            print("⚠️ Son non trouvé: \(sound.rawValue)")
            // Fallback sur le son système
            playSystemFallback(for: sound)
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.5
            audioPlayer?.play()
        } catch {
            print("❌ Erreur lecture son: \(error.localizedDescription)")
            playSystemFallback(for: sound)
        }
    }
    
    /// Son système de secours
    private func playSystemFallback(for sound: SoundEffect) {
        switch sound {
        case .eat:
            AudioServicesPlaySystemSound(1057)
        case .drink:
            AudioServicesPlaySystemSound(1104)
        case .pet:
            AudioServicesPlaySystemSound(1001)
        case .happy:
            AudioServicesPlaySystemSound(1025)
        case .sad:
            AudioServicesPlaySystemSound(1053)
        case .celebrate:
            AudioServicesPlaySystemSound(1026)
        case .tap:
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    /// Arrête le son en cours
    func stopSound() {
        audioPlayer?.stop()
    }
}

// MARK: - Extension pour AudioServices

import AudioToolbox

extension SoundManager {
    /// Vibration simple
    func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    /// Son de notification
    func playNotificationSound() {
        AudioServicesPlaySystemSound(1007)  // SMS-received sound
    }
}
