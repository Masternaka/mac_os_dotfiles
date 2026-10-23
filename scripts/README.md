# scripts

Scripts d'installation pour la configuration macOS du dépôt.

## stow_setup.sh

Installe GNU Stow puis propose un menu interactif pour choisir les configurations à relier.

### Ce que fait le script

1. Installe Homebrew s'il est absent.
2. Installe GNU Stow.
3. Détecte les paquets Stow du dépôt (dossiers contenant `.config/`).
4. Affiche un menu : saisir les numéros des paquets à lier, ou `0`/Entrée pour n'en lier aucun.
5. Sauvegarde les configurations existantes des paquets sélectionnés et crée leurs liens.

Par défaut, aucun lien n'est créé. En entrée non interactive, le script s'arrête après l'installation de Stow sans rien relier.

### Utilisation

Depuis la racine du dépôt :

```bash
./scripts/stow_setup.sh
```

Ce script peut être lancé seul pour ne gérer que les liens. `terminal_setup.sh` et `yazi_setup.sh` installent aussi Stow et créent leurs propres liens : l'ordre d'exécution n'est donc pas critique.

## terminal_setup.sh

Installe les outils du terminal et relie les configurations gérées par GNU Stow.

### Ce que fait le script

1. Installe Homebrew s'il est absent.
2. Installe Ghostty, Herdr, Starship, Zoxide, fzf, eza, bat, GNU Stow et la police JetBrains Mono Nerd Font.
3. Clone les plugins Zsh `zsh-autosuggestions` et `zsh-syntax-highlighting`.
4. Écrit `~/.zshrc` avec les initialisations de Starship et Zoxide, ainsi que les alias modernes.
5. Sauvegarde les configurations existantes puis crée les liens Stow pour `ghostty`, `herdr` et `starship`.

### Utilisation

Depuis la racine du dépôt :

```bash
./scripts/terminal_setup.sh
```

Le script doit être exécuté depuis un clone du dépôt : il s'arrête si les paquets Stow sont introuvables.

### Remarque

Ce script n'est pas en mode simulation : il installe des logiciels et modifie `~/.zshrc` et `~/.config`. Il est destiné à être relu puis lancé manuellement sur la machine cible.

## yazi_setup.sh

Installe Yazi, ses outils de prévisualisation et relie sa configuration Stow.

### Ce que fait le script

1. Installe Homebrew s'il est absent.
2. Installe Yazi, ffmpeg, sevenzip, jq, poppler, fd, ripgrep, fzf, zoxide, resvg, ImageMagick et GNU Stow.
3. Sauvegarde les éventuels fichiers `~/.config/yazi/{yazi,keymap,theme}.toml`.
4. Crée le lien Stow du paquet `yazi`.

### Utilisation

Depuis la racine du dépôt :

```bash
./scripts/yazi_setup.sh
```

Comme `terminal_setup.sh`, ce script n'est pas en mode simulation et doit être relu avant exécution.
