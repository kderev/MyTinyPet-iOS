# 🐾 MyTinyPet

> Un adorable jeu de type Tamagotchi développé en SwiftUI pour iOS

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 📱 Description

**MyTinyPet** est un jeu de compagnon virtuel où vous adoptez et prenez soin d'un petit animal mignon. Inspiré des Tamagotchi classiques, ce jeu vous permet de nourrir, abreuver et câliner votre animal pour le garder heureux !

### 🎮 Caractéristiques principales

- **3 animaux adorables** : Cochon 🐷, Chien 🐶 ou Grenouille 🐸
- **Graphismes 2D** : Style cartoon mignon entièrement dessiné avec SwiftUI
- **Système de jauges** : Faim, soif et affection à gérer
- **Expressions animées** : Votre animal réagit à vos actions (heureux, triste, fatigué...)
- **Compteur de jours** : Suivez combien de temps vous prenez soin de votre compagnon
- **Sauvegarde automatique** : Vos progrès sont conservés entre les sessions
- **Notifications** : Rappels quand votre animal a besoin de vous

## 📸 Captures d'écran

```
┌─────────────────────┐    ┌─────────────────────┐
│    🐾 MyTinyPet     │    │      Jour 15        │
│                     │    │                     │
│   Choisis ton       │    │      (◕‿◕)          │
│     animal          │    │     🐷 Pinky        │
│                     │    │                     │
│  🐷    🐶    🐸     │    │ ████████░░ Faim     │
│                     │    │ ██████░░░░ Soif     │
│   [Continuer →]     │    │ █████████░ Affection│
│                     │    │                     │
│                     │    │  🍎    💧    ❤️     │
└─────────────────────┘    └─────────────────────┘
     Écran de choix            Jeu principal
```

## 🛠️ Installation

### Prérequis

- macOS 13.0+ (Ventura ou plus récent)
- Xcode 15.0+
- iOS 17.0+ (pour le simulateur ou appareil)

### Étapes d'installation

1. **Cloner ou télécharger le projet**
   ```bash
   git clone https://github.com/votre-repo/MyTinyPet.git
   cd MyTinyPet
   ```

2. **Ouvrir dans Xcode**
   ```bash
   open MyTinyPet.xcodeproj
   ```

3. **Sélectionner votre appareil/simulateur**
   - Choisissez un iPhone dans la barre d'outils Xcode

4. **Compiler et lancer**
   - Appuyez sur `Cmd + R` ou cliquez sur le bouton ▶️

### Configuration du Team ID (pour appareil réel)

Si vous voulez installer l'app sur un vrai iPhone :

1. Sélectionnez le projet dans le navigateur
2. Allez dans "Signing & Capabilities"
3. Sélectionnez votre équipe de développement Apple

## 📁 Structure du projet

```
MyTinyPet/
├── MyTinyPet.xcodeproj/     # Configuration Xcode
├── MyTinyPet/
│   ├── MyTinyPetApp.swift   # Point d'entrée de l'app
│   ├── Info.plist           # Configuration iOS
│   │
│   ├── Models/              # Modèles de données
│   │   ├── PetModel.swift   # Définition de l'animal
│   │   └── GameState.swift  # État du jeu & persistance
│   │
│   ├── ViewModels/          # Logique métier (MVVM)
│   │   └── GameViewModel.swift
│   │
│   ├── Views/               # Interfaces utilisateur
│   │   ├── ContentView.swift      # Vue racine
│   │   ├── OnboardingView.swift   # Choix de l'animal
│   │   ├── MainGameView.swift     # Écran de jeu
│   │   ├── SettingsView.swift     # Paramètres
│   │   ├── StatsView.swift        # Statistiques
│   │   └── Components/
│   │       └── PetAvatarView.swift # Composant animal
│   │
│   ├── Utilities/           # Outils et gestionnaires
│   │   ├── NotificationManager.swift
│   │   └── SoundManager.swift
│   │
│   └── Assets.xcassets/     # Ressources graphiques
│       ├── AppIcon.appiconset/
│       └── AccentColor.colorset/
│
└── README.md                # Ce fichier
```

## 🎯 Architecture

Le projet utilise l'architecture **MVVM** (Model-View-ViewModel) :

```
┌──────────────┐     ┌──────────────────┐     ┌──────────────┐
│    Views     │ ←── │   ViewModel      │ ←── │    Models    │
│  (SwiftUI)   │     │ (GameViewModel)  │     │ (PetModel)   │
└──────────────┘     └──────────────────┘     └──────────────┘
       ↓                      ↓                      ↓
   Interface           Logique métier          Données
   utilisateur         & état                  & persistance
```

### Flux de données

1. L'utilisateur interagit avec les **Views**
2. Les actions sont transmises au **ViewModel**
3. Le ViewModel met à jour les **Models**
4. Les changements sont propagés via `@Published`
5. Les Views se rafraîchissent automatiquement

## 🎨 Design des animaux

Les animaux sont entièrement dessinés en SwiftUI avec des formes géométriques :

### Cochon 🐷
- Couleurs : Rose clair (#FFB6C1) et rose vif (#FF69B4)
- Caractéristiques : Museau ovale, oreilles pointues, nez avec narines

### Chien 🐶
- Couleurs : Brun clair (#DEB887) et brun foncé (#8B4513)
- Caractéristiques : Oreilles tombantes, truffe noire, langue rose

### Grenouille 🐸
- Couleurs : Vert clair (#90EE90) et vert forêt (#228B22)
- Caractéristiques : Yeux globuleux, grande bouche, taches

## 🔧 Personnalisation

### Modifier la vitesse de dégradation

Dans `GameViewModel.swift` :
```swift
// Points perdus par seconde
private let decayRate: Double = 0.05  // ~3 points/minute
```

### Changer les couleurs

Dans `PetModel.swift`, modifiez les propriétés `primaryColor` et `secondaryColor` :
```swift
var primaryColor: Color {
    switch self {
    case .pig: return Color(hex: "FFB6C1")
    // ...
    }
}
```

### Ajouter un nouvel animal

1. Ajoutez un nouveau cas dans `PetType` enum
2. Créez une nouvelle vue `NouvelAnimalView` dans `PetAvatarView.swift`
3. Ajoutez les couleurs et propriétés associées

## 📲 Fonctionnalités

| Fonctionnalité | Description | Statut |
|----------------|-------------|--------|
| Choix d'animal | 3 animaux disponibles | ✅ |
| Actions de soin | Nourrir, abreuver, câliner | ✅ |
| Jauges dynamiques | Faim, soif, affection | ✅ |
| Expressions | 7 humeurs différentes | ✅ |
| Animations | Réactions aux actions | ✅ |
| Persistance | Sauvegarde automatique | ✅ |
| Notifications | Rappels locaux | ✅ |
| Statistiques | Suivi des actions | ✅ |
| Renommer l'animal | Personnalisation | ✅ |
| Feedback haptique | Retour tactile | ✅ |

## 🐛 Dépannage

### L'app ne compile pas

1. Vérifiez que vous utilisez Xcode 15+
2. Nettoyez le build : `Product > Clean Build Folder`
3. Supprimez les données dérivées : `~/Library/Developer/Xcode/DerivedData`

### Les notifications ne fonctionnent pas

1. Vérifiez les autorisations dans Réglages iOS
2. Sur simulateur, utilisez `Features > Push Notifications`

### Les données ne sont pas sauvegardées

1. L'app utilise `UserDefaults` pour la persistance
2. Vérifiez que l'app n'est pas supprimée entre les sessions

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## 🙏 Crédits

- Développé avec ❤️ en SwiftUI
- Inspiré par les Tamagotchi originaux de Bandai
- Icônes emoji par Apple

---

**Amusez-vous bien avec votre petit compagnon virtuel ! 🐾**

---
*Ready for App Store review* ✅

---
*Ready for App Store review* ✅

---
*Ready for App Store review* ✅
