# Ghostty Configuration

Configuration complète pour Ghostty avec thème Gruvbox intégré et fonctionnalités professionnelles.

## 📁 Structure

```
ghostty/
├── config              # Configuration principale
├── themes/
│   └── gruvbox-dark.ghostty  # Thème Gruvbox
└── README.md           # Documentation
```

## 🎨 Thème Gruvbox

Le thème `gruvbox-dark` est basé sur la palette de couleurs Gruvbox classique, cohérente avec les autres terminaux de cette configuration (Alacritty, Kitty, WezTerm).

### Couleurs principales
- **Background**: `#282828` (gruvbox dark)
- **Foreground**: `#ebdbb2` (gruvbox light)
- **Cursor**: `#928374` (gruvbox gray)
- **Selection**: `#458588` (gruvbox blue)

## ⚙️ Configuration principale

### Performance
- `gpu-acceleration = yes` - Accélération matérielle pour un rendu fluide
- `resize-delay = 0` - Redimensionnement instantané

### Police
- `font-family = "JetBrainsMono Nerd Font"` - Police avec support des icônes
- `font-size = 11` - Taille optimale pour la lisibilité
- `font-style = Regular` - Style standard

### Fenêtre
- `window-theme = ghostty` - Thème natif Ghostty
- `window-padding-x/y = 14` - Marges confortables
- `resize-overlay = never` - Pas d'overlay lors du redimensionnement
- `confirm-close-surface = false` - Ne demande pas de confirmation à la fermeture
- `gtk-toolbar-style = flat` - Barre d’outils plate et minimaliste

### Curseur
- `cursor-style = "block"` - Curseur bloc classique
- `cursor-style-blink = false` - Curseur statique

### Accessibilité
- `adjust-cursor-thickness = 1` - Épaisseur optimisée du curseur
- `adjust-font-baseline = 1` - Alignement parfait de la police
- `adjust-underline-position = -1` - Positionnement des soulignements

### Presse-papiers & souris
- `clipboard-read/write = yes` - Accès complet au presse-papiers
- `select-to-clipboard = yes` - Sélection automatique vers le presse-papiers
- `mouse-hide-while-typing = yes` - Cache le curseur pendant la saisie
- `mouse-scroll-multiplier = 0.95` - Défilement légèrement ralenti pour plus de précision

### Shell Integration
- `shell-integration = detect` - Détection automatique du shell
- `shell-integration-features = cursor,sudo,title` - Fonctionnalités avancées

### Terminal Features
- `quit-after-last-window-closed = yes` - Fermeture automatique
- `working-directory = inherit` - Hérite du répertoire courant
- `auto-window = true` - Gestion automatique des fenêtres
- `copy-on-select = no` - Ne copie pas automatiquement la sélection

## ⌨️ Raccourcis clavier

### Presse-papiers
- `Shift+Insert` - Coller depuis le presse-papiers
- `Ctrl+Insert` - Copier vers le presse-papiers

### Redimensionnement des splits
- `Super+Ctrl+Shift+Alt+↓` - Agrandir vers le bas (100px)
- `Super+Ctrl+Shift+Alt+↑` - Agrandir vers le haut (100px)
- `Super+Ctrl+Shift+Alt+←` - Agrandir vers la gauche (100px)
- `Super+Ctrl+Shift+Alt+→` - Agrandir vers la droite (100px)

## 🚀 Installation

1. **Copier les fichiers** dans le répertoire de configuration Ghostty :
   ```bash
   cp -r ghostty/* ~/.config/ghostty/
   ```

2. **Redémarrer Ghostty** pour appliquer les changements.

## 🎯 Personnalisation

### Changer la taille de police
Modifier `font-size` dans le fichier `config` :
```toml
font-size = 12  # Plus grand
font-size = 10  # Plus petit
```

### Ajuster les marges
Modifier `window-padding-x` et `window-padding-y` :
```toml
window-padding-x = 10  # Marges horizontales
window-padding-y = 8   # Marges verticales
```

### Créer un nouveau thème
1. Copier `themes/gruvbox-dark.ghostty`
2. Modifier les couleurs hexadécimales
3. Mettre à jour `theme = "nom-du-theme"` dans `config`

### Désactiver des fonctionnalités
Commenter les lignes non désirées avec `#` :
```toml
# gpu-acceleration = yes  # Désactiver l'accélération GPU
```

## 🔧 Dépannage

### Le thème ne s'applique pas
- Vérifier que le fichier `themes/gruvbox-dark.ghostty` existe
- Redémarrer Ghostty complètement

### Police non trouvée
- Installer "JetBrainsMono Nerd Font" :
  ```bash
  brew install font-jetbrains-mono-nerd-font
  ```

### Raccourcis ne fonctionnent pas
- Vérifier les conflits avec les raccourcis système
- Ajuster les combinaisons de touches si nécessaire

## 📝 Notes

- Cette configuration est optimisée pour macOS
- Les couleurs sont cohérentes avec les autres terminaux du dotfiles
- Les performances sont optimisées pour une utilisation intensive
- L'accessibilité est prise en compte avec des ajustements fins

---

**Dernière mise à jour**: 2026-02-16
