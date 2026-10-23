# Zsh

Configuration du shell Zsh, gérée par GNU Stow.

## Contenu

- `.zshrc` : configuration principale, destinée à `~/.zshrc`.

## Réglages

- Initialisation de Homebrew pour Apple Silicon (`/opt/homebrew`) et Intel (`/usr/local`).
- Complétion Zsh via `compinit`.
- Plugin `zsh-autosuggestions`.
- Starship, Zoxide (`cd` intelligent) et fzf.
- `zsh-syntax-highlighting` chargé en dernier.
- Alias modernes pour `ls`, `ll` et `cat`.

## Installation avec Stow

Depuis la racine du dépôt :

```bash
stow --target="$HOME" --restow --no-folding zsh
```

Pour retirer le lien :

```bash
stow --target="$HOME" --delete zsh
```

Le script `bash scripts/terminal_setup.sh --dry-run` vérifie les outils et plugins déjà présents ; `--apply` crée ensuite le lien. Il n’installe rien.

Le paquet Zsh peut aussi être lié seul : les outils et plugins absents ne sont pas chargés, et les commandes standard restent disponibles. Les alias modernes sont activés uniquement lorsque leurs outils existent.
