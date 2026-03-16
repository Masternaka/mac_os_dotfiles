# Nerd Fonts (macOS)

Ce dossier contient un script simple pour installer des **Nerd Fonts** sur macOS en utilisant **Homebrew**.

## 🌟 Ce que fait le script

Le script `install_nerd_fonts.sh` :

- Vérifie que vous êtes bien sur macOS (sinon il s'arrête).
- Vérifie que **Homebrew** est installé, et l'installe si nécessaire.
- Ajoute le tap `homebrew/cask-fonts`.
- Installe plusieurs polices Nerd Font populaires (JetBrains Mono, Caskaydia Mono, Fira Code, Meslo LG).
- Affiche un message de fin et indique que les applications peuvent nécessiter un redémarrage pour prendre en compte les nouvelles polices.

## 🚀 Utilisation

1. Ouvrez un terminal.
2. Placez-vous dans ce dossier :

   ```bash
   cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")"
   ```

3. Rendre le script exécutable (si ce n'est pas déjà le cas) :

   ```bash
   chmod +x install_nerd_fonts.sh
   ```

4. Lancer le script :

   ```bash
   ./install_nerd_fonts.sh
   ```

5. Une fois terminé, redémarrez les applications (Terminal, éditeur, etc.) pour voir les nouvelles polices.

## 🛠️ Personnalisation

Pour ajouter ou supprimer des polices, modifiez simplement la variable `fonts=( ... )` dans `install_nerd_fonts.sh`.

## 📌 Remarque

Ce script est conçu pour macOS. Si vous êtes sur Linux, utilisez plutôt le script officiel de Nerd Fonts disponible sur leur dépôt GitHub.
