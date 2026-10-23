# mac_os_dotfiles

Configuration personnelle pour macOS : terminal Ghostty, multiplexeur Herdr, prompt Starship et gestionnaire de fichiers Yazi.

Les fichiers sont organisés en **paquets [GNU Stow](https://www.gnu.org/software/stow/)** : chaque dossier de premier niveau reproduit l'arborescence du répertoire personnel.

## Structure

```
.
├── ghostty/           # ~/.config/ghostty/config
├── herdr/             # ~/.config/herdr/config.toml
├── starship/          # ~/.config/starship.toml
├── yazi/              # ~/.config/yazi/yazi.toml
├── scripts/           # scripts d'installation
└── .github/           # configuration GitHub
```

## Prérequis

- macOS
- [Homebrew](https://brew.sh)
- GNU Stow : `brew install stow`

## Installation

1. Installer GNU Stow et choisir les configurations à lier :

```bash
./scripts/stow_setup.sh
```

Le script affiche un menu interactif des paquets disponibles ; appuyer sur Entrée (choix `0`) ne crée aucun lien.

2. Installer les outils du terminal (Ghostty, Herdr, Starship, etc.) :

```bash
./scripts/terminal_setup.sh
```

3. Installer Yazi et ses outils de prévisualisation :

```bash
./scripts/yazi_setup.sh
```

`stow_setup.sh` peut être lancé seul pour ne gérer que les liens, ou avant les autres scripts pour préparer la machine.

Pour ne créer que les liens manuellement, depuis la racine du dépôt :

```bash
stow --target="$HOME" --restow --no-folding ghostty herdr starship yazi
```

## Désinstallation des liens

```bash
stow --target="$HOME" --delete ghostty herdr starship yazi
```

Les sauvegardes créées par les scripts restent sous la forme `*.backup.*` dans `~/.config`.

## Remarque

Les scripts ne sont pas en mode simulation : ils installent des logiciels et modifient la configuration de l'utilisateur. Ils sont destinés à être relus puis lancés manuellement.
