# Yazi

Configuration simple pour [Yazi](https://yazi-rs.github.io), le gestionnaire de fichiers terminal.

## Contenu

- `.config/yazi/yazi.toml` : configuration principale, destinée à `~/.config/yazi/yazi.toml`.

## Réglages

- Panneau d'aperçu plus large (`ratio = [1, 3, 4]`).
- Tri naturel et dossiers affichés en premier.
- Taille des fichiers affichée dans la liste (`linemode = "size"`).
- Fichiers cachés masqués par défaut, à afficher avec la touche `.`.
- Aperçu limité à 1000 × 1000 pixels.

Les raccourcis clavier restent ceux de Yazi : `h`/`l` pour naviguer, `s` pour chercher avec `fd`, `S` avec `ripgrep`, `z` avec `fzf`, `Z` avec `zoxide`.

## Installation

Le script dédié vérifie Yazi et ses outils déjà présents, puis prépare le lien Stow :

```bash
bash scripts/yazi_setup.sh --dry-run
```

Après relecture, remplacer `--dry-run` par `--apply` pour créer le lien.

Ou manuellement, depuis la racine du dépôt :

```bash
stow --target="$HOME" --restow --no-folding yazi
```

Pour retirer le lien :

```bash
stow --target="$HOME" --delete yazi
```

## Lancement

```bash
yazi
```

## Référence

- Documentation : https://yazi-rs.github.io/docs/configuration/overview/
- Schéma de configuration : https://yazi-rs.github.io/schemas/yazi.json
