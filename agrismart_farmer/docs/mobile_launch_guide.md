# Guide de Lancement : AgriSmart Farmer (Mobile)

Pour lancer l'application mobile et tester les interfaces, suivez ces étapes dans l'ordre.

## 1. Prérequis
- **Flutter SDK** installé sur votre machine.
- **VS Code** ou **Android Studio** avec les extensions Flutter/Dart.
- Un **Émulateur Android**, un **Simulateur iOS**, ou un **appareil physique** connecté.

## 2. Préparation du Projet
Ouvrez votre terminal dans le dossier du projet mobile :
```bash
cd c:\Users\rayen\Downloads\SprintWeb-main\agrismart_farmer
```

## 3. Installation des Dépendances
Récupérez tous les packages nécessaires :
```bash
flutter pub get
```

## 4. Génération de Code (Optionnel mais recommandé)
Puisque le projet utilise **Freezed** et **Riverpod**, il est crucial de générer les fichiers de code manquants :
```bash
dart run build_runner build --delete-conflicting-outputs
```

## 5. Lancement de l'Application
Une fois les dépendances installées et le code généré, vous pouvez lancer l'application :

### Via la ligne de commande :
```bash
flutter run
```

### Via VS Code :
1. Ouvrez le dossier `agrismart_farmer` dans VS Code.
2. Appuyez sur **F5** ou allez dans l'onglet **Exécuter et déboguer**.
3. Sélectionnez votre appareil dans la barre d'état en bas à droite.

## 6. Structure pour les Tests d'Interface
- Les écrans principaux se trouvent dans : `lib/features/`
- Le thème global (couleurs, polices) est dans : `lib/core/theme/app_theme.dart`
- La navigation est gérée par **GoRouter** dans : `lib/core/utils/main_navigation.dart`

> [!TIP]
> Si vous rencontrez des erreurs de "fichiers manquants" (ex: `.freezed.dart` ou `.g.dart`), relancez l'étape 4 pour régénérer le code.
