# Configuration Kitty Terminal

Cette configuration pour Kitty Terminal utilise le thème Catppuccin Macchiato et optimise l'expérience utilisateur sur macOS avec des fonctionnalités avancées et des raccourcis pratiques.

## 📁 Structure des fichiers

```
kitty/
├── kitty.conf              # Configuration principale
├── quick-access-terminal.conf  # Configuration accès rapide
├── themes/
│   ├── catppuccin-macchiato.conf  # Thème actif
│   ├── dracula.conf
│   ├── gruvbox.conf
│   └── nord.conf
└── README.md               # Ce fichier
```

## 🎨 Thème

### Catppuccin Macchiato
Le thème Catppuccin Macchiato est activé par défaut avec une palette de couleurs pastel apaisante :
- **Fond** : `#24273A` (bleu foncé)
- **Texte** : `#CAD3F5` (bleu clair)
- **Curseur** : `#F4DBD6` (rose pâle)
- **Transparence** : Non configurée (opaque par défaut)

## ⚙️ Configuration détaillée

### Fenêtre et affichage
- **Dimensions initiales** : 220x50 caractères
- **Espacement** : 8px de padding
- **Bordure** : 1pt avec bordures minimales
- **Placement** : Centré
- **Mémorisation** : Taille de fenêtre mémorisée
- **Retour à la ligne** : Activé (par défaut)
- **Liens hypertexte** : Cibles affichées (par défaut)
- **Ouverture d'URL** : Utilise l'application par défaut

### Police
- **Famille** : JetBrainsMono Nerd Font
- **Taille** : 13.0pt (optimisée pour la lisibilité)
- **Ligatures** : Activées pour une meilleure typographie
- **Variations** : Auto pour gras/italique/bold-italic
- **Rendu** : Stratégie legacy pour macOS (CoreText)

### Curseur
- **Forme** : Bloc (`block`)
- **Couleur** : `#F4DBD6` (rose pâle Catppuccin)
- **Clignotement** : Intervalle de 0.5s, arrêt après 15s
- **Trail** : Non activé

### Onglets
- **Position** : En bas (`tab_bar_edge bottom`)
- **Style** : Powerline avec style incliné (`slanted`)
- **Template** : Affiche l'index et le titre (`{index}: {title}`)

### Comportement
- **Historique** : 10,000 lignes de scrollback
- **Pager scrollback** : less avec options spécifiques
- **Défilement molette** : Multiplicateur 5.0
- **Copie** : Pas de copie automatique sur sélection (`copy_on_select no`)
- **Copie propre** : Supprime les espaces en fin de ligne intelligemment
- **Navigation** : Focus ne suit pas la souris (`focus_follows_mouse no`)
- **Notifications** : Visuelles seulement (pas de son)
- **Cloche** : Non configurée (défaut)
- **Contrôle distant** : Non activé
- **Fermeture** : Confirmation par défaut

## ⌨️ Raccourcis clavier

### Gestion des fenêtres
- `Cmd+C` : Copier vers le presse-papiers
- `Cmd+V` : Coller depuis le presse-papiers
- `Cmd+N` : Nouvelle fenêtre
- `Cmd+W` : Fermer la fenêtre

## 🍎 Intégration macOS

### Optimisations spécifiques
- **Option comme Alt** : `macos_option_as_alt left` (touche Option gauche utilisable comme Alt)
- **Couleur barre de titre** : `macos_titlebar_color background` (suit le fond)
- **Quitter automatique** : `macos_quit_when_last_window_closed yes` (ferme avec la dernière fenêtre)
- **Fenêtre redimensionnable** : `macos_window_resizable yes`
- **Espace colorimétrique** : `macos_colorspace displayp3` (pour écrans Retina/P3)
- **Répétition de touche** : `macos_traditional_fast_key_repeat yes` (classique)

### Compatibilité
- Support des URLs cliquables
- Intégration shell activée
- Contrôle distant autorisé

## 🚀 Performance

### Structure de la configuration

Le fichier `kitty.conf` est organisé en sections commentées :

1. **Thèmes** : Inclusion du thème Catppuccin Macchiato
2. **Fonts** : Configuration de la police JetBrainsMono Nerd Font avec ligatures
3. **Curseur** : Forme bloc avec clignotement
4. **Défilement** : Historique et pager
5. **Souris** : Comportement et URLs
6. **Performance** : Délais de repaint et input
7. **Fenêtre** : Dimensions, padding, placement
8. **Onglets** : Style Powerline en bas
9. **macOS** : Options spécifiques macOS
10. **Raccourcis** : Mappings Cmd pour copier/coller et fenêtres

## 🛠️ Personnalisation

### Changer de thème
1. Commentez la ligne actuelle dans `kitty.conf` :
   ```conf
   # include ~/.config/kitty/themes/catppuccin-macchiato.conf
   ```
2. Ajoutez le nouveau thème :
   ```conf
   include ~/.config/kitty/themes/votre-theme.conf
   ```

### Modifier le curseur
Dans la section "3. CURSEUR" :
```conf
cursor_shape block        # block, beam, underline
cursor_blink_interval 0.5  # Intervalle de clignotement (secondes)
cursor_stop_blinking_after 15  # Arrêt après X secondes
```

### Personnaliser les onglets
Dans la section "8. ONGLETS" :
```conf
tab_bar_edge bottom      # top, bottom
tab_bar_style powerline  # powerline, fade, separator, hidden
tab_powerline_style slanted  # slanted, angled, round
tab_title_template " {index}: {title} "  # Template personnalisé
```

### Ajouter des raccourcis
Utilisez le format :
```conf
map vos+raccourcis votre_commande
```

## 📝 Installation

1. Installer Kitty :
   ```bash
   brew install --cask kitty
   ```

2. Copier la configuration :
   ```bash
   cp -r kitty/* ~/.config/kitty/
   ```

3. Redémarrer Kitty pour appliquer les changements

**Note** : La configuration est déjà dans `~/.config/kitty/`, pas besoin de créer de lien symbolique.

## 📝 Comment configurer le quick-acces-terminal

1. Enregistrer le service macOS
Depuis kitty, lance le kitten une première fois pour faire apparaître la fenêtre, puis ferme-la avec ```ctrl+d``` pour enregistrer le service macOS.

   ```bash
   kitten quick-access-terminal
   # puis Ctrl+D pour fermer
   ```

1. Faire apparaître l'entrée dans les Services (workaround)
Certains utilisateurs ne voient pas la section "General" dans les raccourcis. Le fix est de lancer manuellement l'app ```kitty-quick-access``` depuis le contenu du package kitty :

   Ouvre le Finder → Applications
   Clic droit sur kitty → Show Package Contents
   Navigue dans le bundle et lance l'app kitty-quick-access
   Ferme avec ```Ctrl+D```

   Cela force l'enregistrement du service et fait apparaître la section General. GitHub

1. Assigner le raccourci global
Va dans System Settings → Keyboard → Keyboard Shortcuts → Services → General et assigne un raccourci à l'entrée "Quick access to kitty".
Un bon choix qui ne conflit pas avec les raccourcis système : ```⌥Space``` ou ```F12```.



## 🔧 Dépannage

### Problèmes courants
- **Police non trouvée** : Installez JetBrainsMono Nerd Font
- **Thème ne s'applique pas** : Vérifiez le chemin du fichier de thème
- **Raccourcis ne fonctionnent pas** : Redémarrez Kitty

### Logs et debug
Activer le mode debug :
```bash
kitty --debug-config
```

## 📚 Ressources

- [Documentation Kitty](https://sw.kovidgoyal.net/kitty/)
- [Thèmes Kitty](https://github.com/kovidgoyal/kitty-themes)
- [Gruvbox Theme](https://github.com/morhetz/gruvbox)
- [Référence de configuration](https://sw.kovidgoyal.net/kitty/conf.html)

## 📝 Notes

- Configuration organisée en sections numérotées pour faciliter la maintenance
- Tous les paramètres sont commentés en français
- Compatible avec macOS, optimisé pour une utilisation quotidienne
- Support complet des Nerd Fonts pour les icônes
- Intégration shell activée pour une meilleure expérience

---

**Dernière mise à jour**: 2026-04-16

*Configuration maintenue pour une expérience terminal optimale sur macOS*
