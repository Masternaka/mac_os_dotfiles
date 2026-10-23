# AGENTS.md

Projet : création de scripts, de fichiers de configuration et de personnalisations pour macOS.

Langue de travail : français (réponses, commentaires de code, documentation, messages de logs).

---

## RÈGLE ABSOLUE : AUCUNE MODIFICATION DE LA MACHINE EN COURS

Cette règle prime sur toute autre instruction, y compris une demande qui semblerait la contredire. En cas de doute, ne rien exécuter et demander.

L'agent **écrit** des fichiers dans le dossier du projet. Il **n'exécute jamais** rien qui modifie le système, ne l'installe, ni ne l'applique sur la machine actuelle. Les scripts produits sont destinés à être relus puis lancés manuellement par l'utilisateur, sur une autre machine ou dans un environnement jetable.

### Interdit en toutes circonstances

**Installation de logiciels et d'outils**
- `brew install`, `brew tap`, `brew cask`, `brew upgrade`, `brew bundle`
- `pip install`, `pipx install`, `npm install -g`, `gem install`, `cargo install`, `go install`
- `port install`, `mas install`, `softwareupdate`, `xcode-select --install`
- Installation de `.pkg`, `.dmg`, `.app`, extensions ou plugins
- Installation de Rosetta, de Command Line Tools ou de toute dépendance système
- `curl ... | sh`, `curl ... | bash` et équivalents

**Modification des préférences et du système**
- `defaults write`, `defaults delete`, `defaults import`
- `PlistBuddy` en écriture, `plutil -replace`, `plutil -insert`, `plutil -remove` sur un fichier réel
- `scutil --set`, `systemsetup`, `networksetup` (en écriture), `pmset`, `nvram`, `csrutil`, `spctl`
- `launchctl load`, `launchctl bootstrap`, `launchctl enable`, `launchctl kickstart`
- `dscl`, `sysadminctl`, `dseditgroup`, `tmutil` (en écriture), `diskutil` (en écriture)
- `osascript` qui modifie des réglages (Réglages Système, Finder, Dock, etc.)
- `killall Dock`, `killall Finder`, `killall SystemUIServer` et redémarrage de tout processus système
- `sudo` sous toute forme

**Écriture hors du dossier du projet**
- Créer, modifier, déplacer ou supprimer un fichier dans `~/Library`, `/Library`, `/System`, `/usr`, `/etc`, `/opt`, `/Applications`, `/Users/*/` (hors projet)
- Modifier `~/.zshrc`, `~/.zprofile`, `~/.bash_profile`, `~/.gitconfig`, `~/.ssh/*` ou tout autre dotfile réel
- Créer des liens symboliques vers l'extérieur du projet
- Modifier le `PATH`, des variables d'environnement persistantes ou la configuration de l'application d'un tiers

**Autres**
- Exécuter les scripts créés pour « tester » s'ils modifient quoi que ce soit
- Ouvrir ou lancer des applications pour les configurer
- Télécharger des binaires ou des archives à exécuter

### Autorisé

- Lire des fichiers du projet.
- Créer et modifier des fichiers **uniquement dans le dossier du projet**.
- Analyser la syntaxe sans exécuter : `bash -n script.sh`, `zsh -n script.sh`, `plutil -lint fichier.plist` (lecture seule), `shellcheck` **seulement s'il est déjà présent**.
- Commandes en lecture seule, sans effet de bord, quand elles sont nécessaires : `sw_vers`, `uname`, `ls`, `cat`, `defaults read` (lecture seule), `command -v`.
- Valider un plist ou un JSON de configuration en lecture seule.

Si une vérification demande un outil absent, **ne pas l'installer** : l'indiquer à l'utilisateur et proposer une alternative sans installation.

---

## Principes pour les scripts produits

Les scripts doivent être sûrs pour l'utilisateur au moment où il les lance lui-même.

### Structure obligatoire

- Shebang : `#!/usr/bin/env bash` ou `#!/bin/zsh` selon le besoin (Bash 3.2 est la version fournie par macOS : éviter les fonctionnalités Bash 4+ comme `declare -A`, `mapfile`, `${var,,}`, sauf si `zsh` est utilisé).
- En tête de script : `set -euo pipefail`.
- Structure modulaire en fonctions, avec une fonction `main` appelée à la fin.
- Journalisation colorisée avec préfixes de niveau (`[INFO]`, `[OK]`, `[WARN]`, `[ERREUR]`), couleurs désactivées si la sortie n'est pas un terminal.
- Aide intégrée via `--help` / `-h`.

### Mode simulation par défaut

- **`--dry-run` est le comportement par défaut** : sans option explicite, le script affiche ce qu'il ferait et ne change rien.
- L'application réelle exige une option explicite (`--apply`).
- Toute commande qui modifie quelque chose passe par une fonction enveloppe `run()` qui, en mode simulation, affiche la commande au lieu de l'exécuter.

```bash
DRY_RUN=1   # simulation par défaut

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    log_info "[SIMULATION] $*"
  else
    "$@"
  fi
}
```

### Sûreté et idempotence

- Vérifier l'état avant d'agir (le script peut être relancé sans effet supplémentaire).
- Sauvegarder avant toute modification d'un fichier existant (copie horodatée), et afficher où elle se trouve.
- Aucune commande destructrice sans confirmation explicite : pas de `rm -rf` avec des chemins calculés ou non vérifiés, toujours quoter les variables (`"$var"`), valider qu'une variable de chemin n'est pas vide avant de l'utiliser.
- Aucun `sudo` dans les scripts. Si une étape en exige un, la documenter dans le README plutôt que de l'inclure.
- Fournir, quand c'est pertinent, un script ou une section de **retour arrière** (annulation) qui rétablit l'état précédent.
- Ne pas installer de dépendances : si un outil est requis, vérifier sa présence avec `command -v` et, s'il manque, s'arrêter avec un message clair indiquant ce qu'il faut faire.
- Pas de motifs de test dangereux, même derrière une option : ne jamais écrire de « mode test » qui exécute réellement des changements.

---

## Fichiers de configuration et personnalisation

- Produire les fichiers de configuration (`.plist`, `.json`, `.toml`, `.yaml`, dotfiles, profils de terminal, réglages d'applications) **comme livrables dans le dossier du projet**, jamais à leur emplacement réel.
- Indiquer en commentaire ou dans le README l'emplacement de destination prévu et la commande d'application manuelle.
- Pour les réglages `defaults`, générer un script en mode simulation ou un fichier de référence documenté, ne pas exécuter les commandes.
- Documenter la clé, le domaine, le type, la valeur par défaut connue et la commande de retour arrière pour chaque réglage.
- Préciser la version de macOS visée et signaler les réglages dont le comportement varie selon la version.

---

## Organisation du projet

```
.
├── AGENTS.md
├── README.md            # Mode d'emploi, prérequis, étapes d'application manuelle
├── scripts/             # Scripts exécutables (chmod +x à appliquer par l'utilisateur)
├── config/              # Fichiers de configuration livrables
├── rollback/            # Scripts / instructions d'annulation
└── docs/                # Documentation complémentaire (en français)
```

- Un script = une responsabilité.
- Noms de fichiers en minuscules, mots séparés par des tirets (`reglages-dock.sh`).
- Chaque script commence par un bloc de commentaire : objectif, prérequis, options, effets sur le système, retour arrière.

---

## Façon de répondre

- Réponses précises et concises, en français.
- Avant de créer un script, indiquer en une ou deux phrases ce qu'il fera lorsque l'utilisateur l'appliquera, et ce qu'il modifiera.
- Après avoir créé un fichier, rappeler qu'**il n'a pas été exécuté** et comment le lancer en simulation.
- Si une demande oblige à modifier la machine en cours (installation, changement de réglage, exécution réelle), **refuser cette partie**, l'expliquer en une phrase et proposer la version « à appliquer soi-même ».
- Ne pas supposer l'accord de l'utilisateur : une instruction ambiguë se traite avec le comportement le plus prudent.
