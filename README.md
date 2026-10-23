# mac_os_dotfiles

Configuration personnelle pour macOS : Ghostty, Herdr, Starship, Yazi, Zsh et Lazygit avec Delta.

Les fichiers sont organisés en **paquets [GNU Stow](https://www.gnu.org/software/stow/)** : chaque dossier de premier niveau reproduit l'arborescence du répertoire personnel.

## Structure

```
.
├── ghostty/           # ~/.config/ghostty/config
├── herdr/             # ~/.config/herdr/config.toml
├── starship/          # ~/.config/starship.toml
├── yazi/              # ~/.config/yazi/yazi.toml
├── zsh/               # ~/.zshrc
├── lazygit/           # ~/Library/Application Support/lazygit/config.yml
├── scripts/           # scripts de liaison
├── .githooks/         # contrôles avant commit, activation manuelle
└── .github/           # configuration GitHub
```

## Prérequis

Cible : macOS, avec Bash 3.2 ou ultérieur et GNU Stow déjà disponible dans le
`PATH`. Les options des applications peuvent varier selon leurs versions ;
leur compatibilité visuelle reste à vérifier sur la machine cible.

Les scripts ne téléchargent, n'installent et ne mettent à jour aucun logiciel.
Préparez les dépendances manuellement sur la machine cible ; voir
[scripts/README.md](scripts/README.md). Si un prérequis manque, le script
s'arrête avant toute sauvegarde ou création de lien, même en simulation.

## Application manuelle

Depuis la racine du dépôt, commencez par une simulation :

```bash
bash scripts/stow_setup.sh --dry-run
bash scripts/terminal_setup.sh --dry-run
bash scripts/yazi_setup.sh --dry-run
```

- `stow_setup.sh` propose les paquets disponibles ; Entrée (`0`) ne crée aucun lien.
- `terminal_setup.sh` vérifie les outils et plugins, puis lie Ghostty, Herdr, Starship et Zsh.
- `yazi_setup.sh` vérifie Yazi et ses outils, puis lie sa configuration.

Le paquet [Lazygit avec Delta](lazygit/README.md) est facultatif et sélectionnable
dans le menu Stow. Il cible Lazygit 0.66.2, avec commandes personnalisées dans
le menu `?` et couleurs adaptées aux terminaux sombres ou clairs.
L'intégration facultative de [GitHub CLI (`gh`)](lazygit/README.md#github-cli-facultatif)
permet aussi de consulter les pull requests et leurs vérifications depuis ce menu.

La simulation vérifie désormais les conflits Stow sans modifier les fichiers.
Les liens vers d'autres emplacements et les options implicites `.stowrc` sont
refusés avant les sauvegardes. En cas d'échec de l'application, le script tente
de restaurer les fichiers déplacés ; voir [les limites et protections](scripts/README.md#sauvegardes-et-limites).

Après relecture, appliquez uniquement les configurations souhaitées en remplaçant
`--dry-run` par `--apply`. L'aide est accessible avec `--help`.
Les commandes utilisent `bash` : aucune permission d'exécution à ajouter.

Pour gérer uniquement les liens manuellement (sans sauvegarde automatique ni
les protections des scripts ; les options personnelles de Stow s'appliquent) :

```bash
stow --target="$HOME" --restow --no-folding ghostty herdr starship yazi zsh
```

Ajouter `lazygit` à cette commande si ce paquet est souhaité.

## Vérifications et automatisation facultative

[Le guide de vérification](docs/verification.md) décrit les contrôles de syntaxe,
ShellCheck et un hook avant commit propre à ce dépôt. Aucun gestionnaire de
plugins ou de hooks supplémentaire n'est nécessaire. Le hook reste inactif tant
que l'utilisateur ne l'a pas activé manuellement ; il fonctionne aussi dans
Lazygit via les hooks natifs de Git.

Pour obtenir un bilan en lecture seule :

```bash
bash scripts/verifier-depot.sh --dry-run
```

Le [guide de validation avant application](docs/validation-avant-application.md)
décrit les essais manuels de déploiement, de conflit et de restauration dans
un macOS jetable. Le bilan statique ne les remplace pas.

## Retour arrière

Voir [les instructions d'annulation](docs/retour-arriere.md) pour retirer les
liens et restaurer les fichiers sauvegardés. Retirer les liens ne restaure pas
automatiquement les anciennes configurations.

Les sauvegardes sont conservées à côté des fichiers remplacés, sous la forme
`*.backup.HORODATAGE` (avec suffixe en cas de collision).

Les scripts sont destinés à être relus puis lancés manuellement sur la machine
cible. Ils n'ont pas été exécutés pendant la préparation de ces corrections.
