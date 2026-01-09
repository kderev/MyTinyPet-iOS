# 🐾 MyTinyPet v2.0

Un adorable jeu Tamagotchi développé en SwiftUI pour iOS.

## ✨ Fonctionnalités

### 🐷🐶🐸 3 Animaux
- **Cochon** - Cherche les truffes
- **Chien** - Attrape la balle  
- **Grenouille** - Chasse aux moustiques

### 📊 4 Jauges à surveiller
- 🍎 Faim
- 💧 Soif
- ❤️ Affection
- 🚽 Besoins (promenade)

### ⭐ Système d'évolution
| Stade | Niveau requis |
|-------|---------------|
| 🐣 Bébé | 1 |
| 🌱 Enfant | 5 |
| ⭐ Adulte | 15 |
| 👑 Senior | 30 |

### 🎮 Mini-jeux quotidiens
- 3 parties par jour maximum
- Jeu différent selon l'animal
- Gagne de l'XP et de l'affection

### 🚶 Promenade
- Glisse pour promener ton animal
- Double-tap pour les besoins
- Bonus XP selon la durée

## 🛠 Installation

1. Ouvre `MyTinyPet.xcodeproj` dans Xcode 15+
2. Sélectionne ton simulateur ou appareil
3. Build & Run (⌘R)

## 📱 Configuration requise

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## 🏗 Architecture

```
MyTinyPet/
├── Models/          # Modèles de données
├── ViewModels/      # Logique MVVM
├── Views/           # Interfaces SwiftUI
│   └── Components/  # Composants réutilisables
└── Utilities/       # Helpers
```

## 📝 Licence

MIT License - Libre d'utilisation
