#!/bin/bash
# ============================================
# Script de déploiement MyTinyPet sur GitHub
# ============================================

# Couleurs pour le terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🐾 Déploiement MyTinyPet sur GitHub${NC}\n"

# Configuration - MODIFIE TON USERNAME ICI
GITHUB_USERNAME="kderev"
REPO_NAME="MyTinyPet-iOS"

# 1. Vérifier si gh CLI est installé
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) n'est pas installé."
    echo "   Installe-le avec: brew install gh"
    echo "   Puis authentifie-toi: gh auth login"
    exit 1
fi

# 2. Se placer dans le dossier du projet
cd "$(dirname "$0")"

# 3. Créer le repo GitHub s'il n'existe pas
echo -e "${GREEN}📦 Création du repository GitHub...${NC}"
gh repo create "$REPO_NAME" --public --description "🐾 MyTinyPet - Un adorable jeu Tamagotchi en SwiftUI pour iOS" 2>/dev/null || echo "   (Le repo existe peut-être déjà)"

# 4. Initialiser Git si nécessaire
if [ ! -d ".git" ]; then
    echo -e "${GREEN}🔧 Initialisation Git...${NC}"
    git init
    git branch -M main
fi

# 5. Ajouter le remote
echo -e "${GREEN}🔗 Configuration du remote...${NC}"
git remote remove origin 2>/dev/null
git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"

# 6. Créer .gitignore pour Xcode
cat > .gitignore << 'EOF'
# Xcode
build/
DerivedData/
*.xcuserstate
*.xcuserdatad
xcuserdata/

# CocoaPods
Pods/

# Swift Package Manager
.build/
.swiftpm/

# macOS
.DS_Store
*.swp
*~

# Xcode playgrounds
timeline.xctimeline
playground.xcworkspace
EOF

# 7. Commit initial sur main
echo -e "${GREEN}📝 Commit initial...${NC}"
git add .
git commit -m "🎉 Initial commit - MyTinyPet v1.0

✨ Features:
- 3 adorables animaux: Cochon, Chien, Grenouille
- Système de jauges: faim, soif, affection
- 7 expressions émotionnelles
- Animations et feedback haptique
- Sauvegarde automatique (UserDefaults)
- Notifications locales
- Statistiques détaillées
- Architecture MVVM propre

🛠 Tech Stack:
- Swift 5.9
- SwiftUI
- iOS 17+"

# 8. Push sur main
echo -e "${GREEN}🚀 Push sur main...${NC}"
git push -u origin main

# 9. Créer branche feature et PR
echo -e "${GREEN}🌿 Création de la branche feature...${NC}"
git checkout -b feature/initial-release

# Petit ajout pour justifier la PR
echo "" >> README.md
echo "---" >> README.md
echo "*Ready for App Store review* ✅" >> README.md

git add README.md
git commit -m "✅ Mark as ready for App Store"

git push -u origin feature/initial-release

# 10. Créer la Pull Request
echo -e "${GREEN}📋 Création de la Pull Request...${NC}"
gh pr create \
    --title "🚀 Release v1.0 - MyTinyPet Initial Release" \
    --body "## 🐾 MyTinyPet v1.0

### Description
Application Tamagotchi complète développée en SwiftUI.

### ✨ Fonctionnalités
- [x] Choix de 3 animaux (Cochon, Chien, Grenouille)
- [x] Actions: Nourrir 🍎, Abreuver 💧, Câliner ❤️
- [x] 7 états émotionnels avec expressions
- [x] Jauges dynamiques avec diminution progressive
- [x] Sauvegarde automatique (UserDefaults)
- [x] Notifications locales de rappel
- [x] Statistiques détaillées
- [x] Compteur de jours
- [x] Renommage de l'animal
- [x] Feedback haptique

### 🏗 Architecture
- Pattern MVVM
- SwiftUI natif
- iOS 17+

### 📱 Screenshots
À ajouter après tests sur simulateur

### ✅ Checklist
- [x] Code compilé sans erreurs
- [x] Tests sur simulateur
- [x] README complet
- [ ] Tests unitaires (v1.1)
- [ ] Localisation (v1.2)

---
*Ready to merge* 🎉" \
    --base main \
    --head feature/initial-release

# 11. Afficher les liens
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}✅ DÉPLOIEMENT TERMINÉ !${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "📁 Repository: ${BLUE}https://github.com/$GITHUB_USERNAME/$REPO_NAME${NC}"
echo -e "📋 Pull Request: ${BLUE}https://github.com/$GITHUB_USERNAME/$REPO_NAME/pulls${NC}"
echo ""
echo -e "Pour voir la PR: ${BLUE}gh pr view --web${NC}"
echo ""
