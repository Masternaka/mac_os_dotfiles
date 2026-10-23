# Lazygit et Delta

Configuration pour macOS, basée sur la documentation de **Lazygit 0.66.2**.
Elle conserve les raccourcis natifs et les fonctions de gestion des fichiers,
branches, commits, stashes, conflits et worktrees. Seuls les réglages utiles à
ce dépôt sont précisés ; les autres gardent leur valeur native.

## Prérequis et destination

Préparer manuellement `git`, `stow`, `lazygit` et `delta` dans le `PATH`.
La police Nerd Font du terminal permet d'afficher les icônes.

Le paquet contient un seul fichier de configuration, destiné au chemin natif
macOS : `~/Library/Application Support/lazygit/config.yml`. Le menu Stow
reconnaît aussi les paquets contenant un dossier `Library/`.
Si `XDG_CONFIG_HOME` ou une option de lancement impose un
autre emplacement, adapter ce choix avant application : ce paquet vise le
chemin macOS par défaut.

Depuis la racine du dépôt, lancer soi-même une simulation et choisir `lazygit` :

```bash
bash scripts/stow_setup.sh --dry-run
```

Après relecture, refaire la sélection avec `--apply`. Le script vérifie
Lazygit et Delta avant toute sauvegarde. Il ne les installe pas et ne lance
pas Lazygit. Un fichier de configuration existant est sauvegardé.

Pour lier manuellement le paquet, sans sauvegarde automatique :

```bash
stow --target="$HOME" --restow --no-folding lazygit
```

Puis, sur la machine cible, ouvrir `lazygit` dans le dépôt souhaité.
Les anciennes versions utilisant `git.pagers` ou `git.paging` nécessitent une
adaptation ; le fichier fourni utilise `git.diffRenderers` de la version ciblée.

## Affichage et utilisation

- Catppuccin Macchiato en sombre, Latte en clair, selon le terminal.
- Panneaux latéraux réduits pour laisser plus de place au diff.
- Delta affiche la coloration syntaxique et les numéros de ligne ; ses thèmes
  de code sont ceux fournis par Delta, sans fichier de thème à télécharger.
- La touche `|` alterne entre Delta et le rendu Git natif, utile pour comparer
  les affichages ou si Delta devient indisponible.
- Aucun réglage global de Git n'est nécessaire pour Delta.

| Action | Raccourci natif |
| --- | --- |
| Aide et commandes disponibles dans le panneau | `?` |
| Changer de panneau | `Tab`, `Maj+Tab`, `1` à `5` |
| Naviguer | Flèches ou `h`, `j`, `k`, `l` |
| Indexer ou désindexer un fichier | `Espace` dans Fichiers |
| Sélectionner des blocs/lignes | `Entrée` dans Fichiers, puis aide `?` |
| Créer un commit | `c` dans Fichiers |
| Modifier un fichier dans l'éditeur existant | `e` dans Fichiers |
| Créer une branche | `n` dans Branches |
| Voir les options de stash | `S` dans Fichiers |
| Fetch / pull / push manuels | `f` dans Fichiers / `p` / `P` |
| Agrandir le panneau principal | `+`, puis `_` pour réduire |
| Quitter | `q` |

L'éditeur vient de `VISUAL`/`EDITOR` et de la détection native de Lazygit.
Les confirmations natives de suppression, amendement et stash sont conservées.
La configuration ne crée pas de dépôt quand Lazygit est lancé hors d'un dépôt.

## Extensions et automatisation

Les extensions utilisent les commandes personnalisées natives de Lazygit,
accessibles depuis `?` dans le panneau Fichiers :

- contrôler les espaces dans les changements indexés ;
- analyser le fichier Bash sélectionné avec ShellCheck, s'il est installé ;
- consulter les pull requests GitHub, les détails de celle de la branche
  courante et ses vérifications, avec GitHub CLI (`gh`).

La deuxième commande vise les scripts Bash, pas les fichiers Zsh ou YAML.
Elle analyse le fichier du dossier de travail, même s'il n'est pas indexé.
Il n'y a pas de gestionnaire de plugins tiers à maintenir.

Le [hook avant commit](../docs/verification.md#contrôle-avant-commit-facultatif)
automatise les contrôles de ce dépôt après activation manuelle. Il ne crée ni
commit, ni push, et ne corrige aucun fichier. Les commits déclenchés dans
Lazygit passent également par ce hook, sauf contournement explicite des hooks.
La configuration retire le préfixe spécial `WIP` qui permet normalement de
les éviter.

Les fetch, pull et push restent manuels. Le déplacement automatique des branches,
l'indexation automatique des conflits résolus et les recherches de mises à jour
sont désactivés ; le rafraîchissement de l'affichage reste actif.

## GitHub CLI facultatif

`gh` complète Lazygit sans être requis pour les liens Stow, Delta ou le hook
avant commit. Les trois commandes GitHub du menu `?` consultent le dépôt dans
lequel Lazygit est ouvert. Elles affichent un message si `gh` est absent.

Sur la machine cible, installer manuellement GitHub CLI. Si Homebrew y est déjà
disponible, la commande de référence est :

```bash
brew install gh
```

Puis se connecter manuellement à son compte et vérifier la connexion :

```bash
gh auth login
gh auth status
```

Choisir l'hôte, le compte et le protocole Git adaptés à ses dépôts. Les données
de connexion restent propres à la machine : ne pas copier de jeton ou de
`hosts.yml` dans ce dépôt. Aucun fichier personnel de configuration `gh` n'est
géré par Stow.

Dans Lazygit, ouvrir `?` depuis le panneau Fichiers et choisir une commande
préfixée **GitHub** :

| Commande | Résultat |
| --- | --- |
| `gh pr status` | État des pull requests associées à son compte dans le dépôt |
| `gh pr view` | Détails de la pull request liée à la branche courante |
| `gh pr checks` | Résultats des vérifications de cette pull request |

Sans pull request pour la branche courante, les deux dernières commandes
l'indiquent. Un dépôt non hébergé sur GitHub ou une connexion absente/invalide
produit le diagnostic de `gh`. Des vérifications en attente ou en échec peuvent
renvoyer un code non nul : cela n'empêche pas de continuer à utiliser Lazygit.
Les résultats s'affichent dans le terminal, sans ouvrir de navigateur ni créer,
commenter ou fusionner de pull request. Les lectures contactent GitHub seulement
lorsque la commande est choisie.

Pour retirer cette intégration seule, supprimer les trois entrées `GitHub` de
`customCommands`. Les autres réglages Lazygit et Delta restent indépendants.

## Retour arrière

Quitter Lazygit, puis retirer le lien depuis ce clone :

```bash
stow --target="$HOME" --delete lazygit
```

Restaurer ensuite la sauvegarde de `config.yml`, si elle existe, en suivant
[le guide de retour arrière](../docs/retour-arriere.md). Retirer le lien ne
désinstalle ni Lazygit ni Delta.

## Références

- [Configuration Lazygit 0.66.2](https://github.com/jesseduffield/lazygit/blob/v0.66.2/docs/Config.md)
- [Intégration de Delta](https://github.com/jesseduffield/lazygit/blob/v0.66.2/docs/Custom_DiffRenderers.md)
- [Commandes personnalisées](https://github.com/jesseduffield/lazygit/blob/v0.66.2/docs/Custom_Command_Keybindings.md)
- [Configuration de Delta](https://dandavison.github.io/delta/configuration.html)
- [Installation de GitHub CLI](https://github.com/cli/cli#installation)
- [Connexion à GitHub CLI](https://cli.github.com/manual/gh_auth_login)
- [État des pull requests](https://cli.github.com/manual/gh_pr_status)
- [Détails d'une pull request](https://cli.github.com/manual/gh_pr_view)
- [Vérifications d'une pull request](https://cli.github.com/manual/gh_pr_checks)

Le YAML a été contrôlé en lecture seule ; aucun lancement de Lazygit, rendu
visuel, déploiement Stow ou installation n'a été effectué pendant sa préparation.
