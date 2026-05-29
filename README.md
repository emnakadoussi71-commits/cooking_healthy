# 🥗 Cooking & Healthy

**Cooking & Healthy** est une application mobile développée en Flutter qui vise à promouvoir une alimentation saine, proposer des recettes équilibrées, et permettre un suivi nutritionnel personnalisé. L'application propose également une mise en relation avec des nutritionnistes.

## ✨ Fonctionnalités Principales

L'application est divisée en plusieurs modules clés pour offrir une expérience complète :

- 🔐 **Authentification** : Inscription et connexion sécurisées des utilisateurs (gérées via Firebase).
- 🏠 **Accueil & Tableau de bord** : Vue d'ensemble personnalisée pour chaque utilisateur.
- 🍲 **Recettes Saines** : Découverte et consultation de recettes saines avec le détail des ingrédients et des instructions.
- 🎯 **Recommandations Personnalisées** : Suggestions de repas adaptées au profil et aux objectifs de l'utilisateur.
- ❤️ **Favoris** : Sauvegarde des recettes préférées pour un accès rapide et facile.
- 📊 **Suivi Nutritionnel** : Suivi des macros, des calories, avec des graphiques interactifs pour analyser sa progression.
- 👩‍⚕️ **Espace Nutritionniste** : Interaction, conseils et potentiellement prise de rendez-vous avec des professionnels de la nutrition.
- ⚙️ **Administration** : Interface dédiée pour gérer le contenu, les utilisateurs et les statistiques.

## 🛠️ Stack Technique et Outils

Le projet repose sur des technologies modernes et performantes :

- **Framework** : [Flutter](https://flutter.dev/) (SDK ^3.10.0)
- **Langage** : Dart
- **Backend & Base de données** : [Firebase](https://firebase.google.com/)
  - *Firebase Auth* : Gestion des utilisateurs
  - *Cloud Firestore* : Base de données NoSQL en temps réel
  - *Firebase Storage* : Stockage des images et fichiers
  - *Firebase Messaging* : Notifications Push
- **Gestion d'état** : [Riverpod](https://riverpod.dev/) (`flutter_riverpod`)
- **Navigation** : [Go Router](https://pub.dev/packages/go_router)
- **UI & Graphiques** :
  - `fl_chart` pour les visualisations nutritionnelles.
  - `cached_network_image` pour l'optimisation des images distantes.
  - `cupertino_icons` pour l'iconographie.

## 🚀 Démarrage Rapide

### Prérequis

Assurez-vous d'avoir installé les éléments suivants sur votre machine :
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.10.0 ou supérieure)
- Un environnement de développement (Android Studio, VS Code, ou IntelliJ)
- Les configurations Firebase locales pour votre projet (`google-services.json` ou `GoogleService-Info.plist`).

### Installation

1. **Cloner le dépôt**
   ```bash
   git clone <votre-url-de-repo>
   cd cooking_healthy
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Lancer l'application**
   Connectez un émulateur ou un appareil physique, puis exécutez :
   ```bash
   flutter run
   ```

## 📁 Architecture du Projet (Dossier `lib/`)

L'architecture du projet est pensée par fonctionnalités ("feature-first") pour une meilleure scalabilité :

```text
lib/
 ├── app/              # Configuration globale de l'application (thème, etc.)
 ├── core/             # Éléments partagés (constantes, erreurs, widgets communs)
 ├── features/         # Fonctionnalités principales (Modules)
 │    ├── admin/       # Panel d'administration
 │    ├── auth/        # Connexion, Inscription, Récupération de mot de passe
 │    ├── favorites/   # Gestion des recettes favorites
 │    ├── home/        # Écran principal et navigation
 │    ├── nutrition/   # Suivi des calories et macros
 │    ├── nutritionist/# Contact et interactions avec les pros
 │    ├── recipes/     # Catalogue et détail des recettes
 │    └── recommendations/ # Algorithme ou suggestions de repas
 ├── router/           # Configuration des routes (Go Router)
 ├── firebase_options.dart # Configuration Firebase générée
 └── main.dart         # Point d'entrée de l'application
```

## 🤝 Contribution

Si vous souhaitez contribuer à l'amélioration de ce projet :
1. Créez un fork du projet.
2. Créez votre branche de fonctionnalité (`git checkout -b feature/NouvelleFonctionnalite`).
3. Validez vos modifications (`git commit -m "Ajout d'une nouvelle fonctionnalité"`).
4. Poussez vers la branche (`git push origin feature/NouvelleFonctionnalite`).
5. Ouvrez une Pull Request.

---
*Créé avec ❤️ pour une vie plus saine.*
