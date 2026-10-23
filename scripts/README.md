# Scripts de liaison

Les scripts vérifient les dépendances déjà présentes, sauvegardent les fichiers
existants puis créent des liens GNU Stow. Aucun téléchargement, installation,
clonage ou mise à jour n'est effectué.

Cible : macOS avec Bash 3.2 ou ultérieur. Exécuter depuis la racine du dépôt avec
`bash` ; aucune permission d'exécution n'est nécessaire.

## Vérification sans application

```bash
bash scripts/verifier-depot.sh --dry-run
```

`verifier-depot.sh` lit les fichiers, vérifie les syntaxes disponibles et
inventorie les outils. Il ne lance aucun script de liaison ni application,
n'utilise pas Stow, ne contacte pas GitHub et n'installe rien. `--apply` n'est
pas accepté car il n'a aucun changement à appliquer. L'aide est disponible
avec `--help`.

Les contrôles supplémentaires utilisent uniquement les outils déjà présents :
ShellCheck pour Bash, Ruby pour YAML, Python avec `tomllib` pour TOML. Les outils
absents sont signalés et les autres contrôles continuent. Les codes de sortie
sont `0` pour un bilan statique terminé, `1` en cas d'échec, `2` si le bilan
est incomplet ou si une option est invalide. Même un code `0` ne valide ni
l'application des configurations ni leur restauration.

Les inventaires des parcours terminal et Yazi peuvent signaler des prérequis
sans utilité pour le seul paquet souhaité : lire le détail, pas seulement le
code de sortie. Les compléments Lazygit/Delta/gh absents sont signalés sans
rendre à eux seuls le bilan incomplet. Les plugins Zsh sont seulement contrôlés
comme fichiers lisibles, pas sourcés ou audités.

Voir [le guide complet de validation](../docs/validation-avant-application.md)
pour les essais manuels dans un environnement jetable.

## Prérequis à préparer manuellement

Les exécutables doivent être disponibles dans le `PATH` du terminal cible.
Si nécessaire, initialisez vous-même votre environnement Homebrew avant de
lancer un script. Les scripts ne requièrent pas Homebrew lui-même.

| Script | Commandes requises |
| --- | --- |
| `stow_setup.sh` | `stow` |
| `terminal_setup.sh` | `stow`, `ghostty`, `herdr`, `nvim`, `starship`, `zoxide`, `fzf`, `eza`, `bat` |
| `yazi_setup.sh` | `stow`, `yazi`, `ffmpeg`, `7zz`, `jq`, `pdftoppm`, `fd`, `rg`, `fzf`, `zoxide`, `resvg`, `magick` |

Si le paquet `lazygit` est sélectionné dans le menu Stow, `lazygit` et `delta`
doivent également être présents avant toute sauvegarde. Le menu détecte les
paquets contenant `.config/`, `Library/` ou `.zshrc`. Le paquet Lazygit utilise
le chemin natif macOS, décrit dans [son guide](../lazygit/README.md).

ShellCheck est utilisé uniquement pour les [vérifications](../docs/verification.md),
pas comme dépendance des scripts de liaison.
GitHub CLI (`gh`) est également facultatif : il sert aux commandes de consultation
GitHub du menu Lazygit, après [préparation manuelle](../lazygit/README.md#github-cli-facultatif).

Pour `terminal_setup.sh`, les deux fichiers suivants doivent aussi être lisibles :

- `~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh`
- `~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`

Préparez les plugins manuellement à partir des projets `zsh-users/zsh-autosuggestions`
et `zsh-users/zsh-syntax-highlighting`. La configuration Ghostty utilise la police
JetBrainsMono Nerd Font : préparez-la également pour obtenir le rendu prévu.
`pdftoppm` est fourni par Poppler, `rg` par ripgrep, `magick` par ImageMagick et
`7zz` par SevenZip. La présence des commandes ne garantit pas la compatibilité
de toutes leurs versions.

Toute dépendance manquante arrête le script avant les changements, y compris en
simulation. Pour lier seulement Zsh sans ces outils, utilisez le menu Stow :
les fonctionnalités absentes sont simplement omises par `.zshrc`.

## Utilisation

```bash
bash scripts/stow_setup.sh --dry-run
bash scripts/terminal_setup.sh --dry-run
bash scripts/yazi_setup.sh --dry-run
```

Sans option, la simulation est également activée. `--help` affiche l'aide.
Après relecture sur la machine cible, remplacez `--dry-run` par `--apply` pour
sauvegarder les fichiers existants et créer les liens.

`stow_setup.sh` propose un menu de paquets. Entrée (`0`) ou une entrée non
interactive ne crée aucun lien. `terminal_setup.sh` lie `ghostty`, `herdr`,
`starship` et `zsh` ; `yazi_setup.sh` lie uniquement `yazi`.

## Sauvegardes et limites

`lib.sh` fournit la journalisation, `run`, les contrôles de dépendances et les
sauvegardes. Il doit être sourcé par les scripts, pas lancé directement.

La procédure commune prépare toutes les destinations avant toute écriture :

1. Vérifier chaque dossier parent. Un dossier symbolique n'est accepté que s'il
   pointe exactement vers le dossier correspondant du paquet de ce clone.
   Les liens vers un ancien clone, un autre dossier ou une cible cassée sont
   refusés. Les liens de fichiers vers une autre cible sont également refusés.
2. Refuser les options implicites de `.stowrc` dans le dossier personnel ou à
   la racine du dépôt. Elles pourraient, par exemple, activer une adoption
   réelle des fichiers. Les fichiers `.stowrc` existants ne sont pas modifiés.
3. Lancer réellement **la simulation en lecture seule de Stow**, même lorsque
   le script est lui-même en mode simulation. Les conflits de structure ou
   entre paquets arrêtent la procédure avant toute sauvegarde.
4. En mode `--apply` seulement, déplacer les fichiers ordinaires existants vers
   des sauvegardes horodatées sans écrasement, puis créer les liens. Les liens
   déjà corrects sont conservés. Une vérification finale contrôle les cibles.

Le contrôle préalable utilise `--simulate --adopt` pour permettre de planifier
le remplacement des fichiers ordinaires qui seront sauvegardés. **L'option
`--adopt` n'est jamais utilisée pendant l'application réelle** : aucune
configuration personnelle n'est importée dans les sources du dépôt.

L'application utilise `--stow --no-folding`, plutôt que `--restow`, afin de ne
pas retirer d'abord les liens déjà fonctionnels. Les liens devenus obsolètes
après suppression d'un fichier source ne sont donc pas nettoyés automatiquement.
Les noms de paquet et les types de fichiers sources sont contrôlés ; les liens
symboliques dans les sources sont refusés. Les fichiers de configuration des
paquets restent sous `.config/`, `Library/` ou dans `.zshrc`.

En cas d'échec après le début des sauvegardes, ou d'interruption par `Ctrl+C`
ou `TERM`, le script tente automatiquement de retirer uniquement ses nouveaux
liens et de remettre les fichiers sauvegardés à leur emplacement initial.
Une destination occupée ou un parent devenu symbolique n'est jamais remplacé :
le script conserve la sauvegarde et affiche le chemin à restaurer manuellement.
Les répertoires vides éventuellement créés par Stow sont laissés en place.

Il ne s'agit pas d'une transaction atomique du système de fichiers. Une coupure
électrique ou un arrêt forcé `KILL` ne permet pas au gestionnaire d'interruption
de s'exécuter : utiliser alors les sauvegardes et le guide ci-dessous. Ne pas
lancer plusieurs applications en parallèle ni modifier les destinations pendant
l'opération. Les parcours de déploiement et de restauration n'ont pas été
exécutés pendant la préparation de cette correction.

Voir [le retour arrière](../docs/retour-arriere.md).
