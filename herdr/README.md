# Herdr

Configuration simple pour [Herdr](https://herdr.dev), le multiplexeur de terminaux orienté agents.

## Contenu

- `.config/herdr/config.toml` : configuration principale, destinée à `~/.config/herdr/config.toml`.

## Réglages

- `onboarding = false` : passe l'assistant de premier lancement.
- Thème Catppuccin avec bascule automatique clair/sombre (`catppuccin-latte` en clair).
- Shell de connexion pour les nouveaux panneaux (`shell_mode = "auto"`).
- Nouveaux panneaux ouverts dans le répertoire courant (`new_cwd = "follow"`).
- Bordures automatiques et indicateurs d'état sous forme de symboles.
- Notifications intégrées à Herdr, en bas à droite.

Les raccourcis clavier restent ceux par défaut, avec le préfixe `ctrl+b`.

## Installation avec Stow

Depuis la racine du dépôt :

```bash
stow --target="$HOME" --restow --no-folding herdr
```

Pour retirer le lien :

```bash
stow --target="$HOME" --delete herdr
```

## Recharger la configuration

Après une modification du fichier :

```bash
herdr server reload-config
```

Ou via le menu global de Herdr, action `reload config`.

## Référence

- Configuration : https://herdr.dev/docs/configuration/
- Référence complète : https://herdr.dev/docs/config-reference/
