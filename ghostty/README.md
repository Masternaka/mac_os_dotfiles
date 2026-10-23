# Ghostty (config + thèmes)

Ce dossier contient la configuration **Ghostty** du dépôt, organisée comme un paquet [GNU Stow](https://www.gnu.org/software/stow/).

## 🧩 Contenu

- `.config/ghostty/config` : configuration principale, liée vers `~/.config/ghostty/config`.
- Le thème Catppuccin (Mocha en sombre, Latte en clair) est fourni par Ghostty : aucun fichier de thème séparé n'est nécessaire.

## ⚙️ Ce que fait la configuration

Le fichier `config` contient des réglages pour :

- l'apparence (thème, police, transparence, marges)
- le comportement de la fenêtre (taille, barre de titres, boutons macOS)
- le curseur, le scrollback, les onglets et les splits
- des raccourcis clavier personnalisés (ex. : `cmd+enter` pour le plein écran)

## 🚀 Installation avec Stow

Depuis la racine du dépôt :

```bash
stow --target="$HOME" --restow --no-folding ghostty
```

Le fichier est alors lié à `~/.config/ghostty/config`. Pour retirer le lien :

```bash
stow --target="$HOME" --delete ghostty
```

Le script `scripts/terminal_setup.sh` installe Ghostty et crée ce lien automatiquement.
