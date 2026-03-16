# Ghostty (config + thèmes)

Ce dossier contient une configuration et des thèmes pour **Ghostty**, un terminal macOS moderne et personnalisable.

## 🧩 Ce que contient ce dossier

- `config` : fichier de configuration principal de Ghostty (correspond à `~/.config/ghostty/config`).
- `themes/` : thèmes Catppuccin (Mocha, Macchiato, Frappé, Latte) compatibles avec Ghostty.

> 📝 Remarque : il n'y a pas de script dans ce dossier, il s'agit d'un ensemble de fichiers de configuration.

## ⚙️ Ce que fait la configuration

Le fichier `config` contient des réglages pour :

- l'apparence (thème, police, transparence, bordures, etc.)
- le comportement de la fenêtre (taille, position, barre de titres, boutons macOS)
- le comportement du curseur, du scrollback, des onglets/splits
- des raccourcis clavier personnalisés (ex. : `cmd+enter` pour fullscreen)

## 🚀 Utilisation

1. Installez Ghostty (par exemple via Homebrew) :

   ```bash
   brew install --cask ghostty
   ```

2. Copiez ce fichier de configuration dans votre dossier utilisateur :

   ```bash
   mkdir -p ~/.config/ghostty
   cp "$(pwd)/config" ~/.config/ghostty/config
   ```

3. Lancez Ghostty. Il prendra automatiquement en compte ce fichier de config.

4. Pour changer de thème, copiez l'un des fichiers du dossier `themes/` vers :

   ```bash
   cp "$(pwd)/themes/catppuccin-mocha.conf" ~/.config/ghostty/theme.conf
   ```

   puis relancez Ghostty (ou utilisez le menu de l'app si disponible).

## 🔧 Personnalisation

- Modifiez `config` pour ajuster la taille de police, les raccourcis, la transparence, etc.
- Modifiez ou ajoutez d'autres fichiers de thème dans `themes/`.

---

✅ Vous pouvez maintenant utiliser ce dossier comme base pour votre configuration Ghostty sur macOS.
