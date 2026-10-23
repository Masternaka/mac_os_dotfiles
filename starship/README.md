# Starship — Catppuccin Macchiato

Configuration [Starship](https://starship.rs) basée sur le thème Catppuccin Macchiato officiel.

## Contenu

- `.config/starship.toml` : configuration principale, destinée à `~/.config/starship.toml`.

## Détails

- Palette `catppuccin_macchiato` avec les couleurs officielles Catppuccin.
- Modules `character`, `git_branch` et `directory` stylés avec cette palette.
- Le symbole du prompt utilise une icône Nerd Font, fournie par `font-jetbrains-mono-nerd-font`.

## Installation avec Stow

Depuis la racine du dépôt :

```bash
stow --target="$HOME" --restow --no-folding starship
```

Pour retirer le lien :

```bash
stow --target="$HOME" --delete starship
```

Après une simulation avec `bash scripts/terminal_setup.sh --dry-run`, l’option `--apply` crée ce lien si les prérequis sont présents ; Starship doit déjà être installé.

## Personnalisation

Modifier `starship/.config/starship.toml` dans le dépôt, puis recharger le shell :

```bash
source ~/.zshrc
```

## Source

- Thème : https://github.com/catppuccin/starship
- Documentation Starship : https://starship.rs/config/
