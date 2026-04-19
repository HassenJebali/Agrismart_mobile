# Guide d'Installation et de Premier Lancement (Flutter)

Ce guide est destiné aux débutants qui souhaitent installer Flutter et lancer le projet **AgriSmart Farmer** pour la toute première fois sur Windows.

## Étape 1 : Télécharger et Installer Flutter
1. **Téléchargement** : Allez sur le site officiel [docs.flutter.dev](https://docs.flutter.dev/get-started/install/windows/desktop) et téléchargez le SDK Flutter (bouton bleu "Flutter SDK").
2. **Extraction** : Extrayez le fichier `.zip` dans un dossier simple comme `C:\flutter`. 
   > [!IMPORTANT]
   > Ne l'installez pas dans `C:\Program Files` car cela peut causer des problèmes de permission.
3. **Variable d'environnement (PATH)** :
   - Dans la recherche Windows, tapez "Variables d'environnement" et ouvrez "Modifier les variables d'environnement système".
   - Cliquez sur **Variables d'environnement**.
   - Dans "Variables utilisateur", cherchez **Path**, cliquez sur **Modifier**.
   - Cliquez sur **Nouveau** et ajoutez le chemin vers le dossier bin de flutter (ex: `C:\flutter\bin`).
   - Validez tout par **OK**.

## Étape 2 : Vérifier l'Installation
Ouvrez un nouveau terminal (PowerShell ou Invite de commandes) et tapez :
```bash
flutter doctor
```
Cela vous dira s'il manque des composants (comme Android Studio ou VS Code). Si tout est vert (ou presque), vous pouvez continuer.

## Étape 3 : Préparer l'Éditeur (VS Code recommandé)
1. Installez **VS Code** si vous ne l'avez pas.
2. Allez dans l'onglet **Extensions** (icône carrés à gauche).
3. Cherchez et installez l'extension **Flutter** (cela installera aussi Dart).

## Étape 4 : Configurer le Projet AgriSmart
Ouvrez votre terminal dans le dossier du projet mobile :
```bash
cd c:\Users\rayen\Downloads\SprintWeb-main\agrismart_farmer
```

### 1. Télécharger les dépendances :
```bash
flutter pub get
```

### 2. Générer les fichiers indispensables (Freezed/Riverpod) :
C'est l'étape la plus importante pour éviter les erreurs de compilation :
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Étape 5 : Lancer le Projet
1. Branchez votre téléphone Android (avec le mode Développeur activé) ou lancez un émulateur.
2. Dans le terminal, tapez :
```bash
flutter run
```
3. Si vous n'avez pas d'appareil, vous pouvez lancer sur **Chrome** en choisissant l'option correspondante quand elle s'affiche.

---
> [!TIP]
> **Une erreur ?** Si Flutter dit qu'il ne connaît pas votre appareil, tapez `flutter devices` pour voir la liste des appareils connectés.
