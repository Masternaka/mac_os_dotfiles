# Valider avant une application sur son Mac

Ce document sépare deux démarches : un bilan en lecture seule, puis des essais
réels dans un **macOS jetable**, par exemple une machine virtuelle avec un
instantané restaurable. Un compte utilisateur secondaire n'isole pas tous les
effets système ; changer simplement `HOME` ne constitue pas un environnement
jetable.

Les commandes de préparation et `--apply` ci-dessous modifient des fichiers.
Elles sont à relire puis à lancer **uniquement dans le macOS jetable**. Elles
n'ont pas été exécutées pendant la rédaction. Aucun mode de test qui applique
des changements n'est ajouté aux scripts du dépôt.

## 1. Faire le bilan sans appliquer

Depuis la racine du clone :

```bash
bash scripts/verifier-depot.sh --dry-run
```

Le script analyse la syntaxe Bash/Zsh, utilise ShellCheck s'il est présent,
vérifie le YAML avec Ruby et le TOML avec Python et `tomllib` si disponibles,
puis inventorie les commandes dans le `PATH` et la présence des plugins Zsh.
Il ne lit pas les identifiants GitHub, ne se connecte pas à un service, ne lance
pas Stow et ne source pas `.zshrc`.

| Code de sortie | Sens |
| --- | --- |
| `0` | Les contrôles statiques prévus sont terminés et les outils inventoriés comme requis ont été trouvés ; aucun déploiement n'est certifié |
| `1` | Au moins un contrôle a échoué : corriger avant de poursuivre |
| `2` | Au moins un contrôle est indisponible ou un prérequis manque, ou option invalide : examiner les messages |

L'inventaire couvre tous les parcours. Un outil Yazi absent peut être ignoré
si seul le paquet Starship est testé. `lazygit`, `delta` et `gh` sont des
compléments facultatifs de cet inventaire ; Lazygit et Delta restent requis
pour sélectionner le paquet `lazygit` dans le menu Stow.

La validation YAML/TOML porte sur la syntaxe, pas sur les schémas des
applications. Le contenu des plugins Zsh externes n'est pas audité. Les
préférences Ghostty, les versions et le rendu restent à vérifier séparément.
Le contrôle Git des espaces couvre les modifications des fichiers déjà suivis,
pas tous les fichiers non suivis. Aucun outil absent n'est installé.

## 2. Préparer le macOS jetable

1. Préparer manuellement GNU Stow et Bash, puis copier le **contenu actuel** du
   dépôt, y compris les nouveaux fichiers non encore commités, dans un dossier
   ordinaire de la VM. Le clone ne doit pas être un dossier partagé avec le Mac
   principal. Ne pas le placer dans `.config` ou un dossier de configuration.
2. Utiliser un utilisateur de la VM sans configuration personnelle à préserver.
   Garder son véritable `HOME` ; ne pas exporter une valeur artificielle.
3. Vérifier qu'il n'existe pas de `.stowrc` personnel ou à la racine du clone,
   sauf dans le scénario dédié. Aucun de ces fichiers ne doit être supprimé sur
   le Mac principal pour faire passer un test.
4. Ouvrir un terminal dans la copie du dépôt et créer un instantané de la VM.
   Restaurer cet instantané **avant chaque scénario indépendant** ci-dessous.
5. Noter `sw_vers`, les versions de Bash et Stow et la révision ou la copie du
   dépôt utilisée. Ne pas importer de secrets ou de données personnelles.

Les premiers essais choisissent uniquement **starship** dans le menu : sa
liaison exige Stow, sans exiger de lancer Starship ou les autres applications.
Le numéro du paquet dépend du menu ; ne pas mémoriser un numéro fixe.

## 3. Simulation et application sans configuration existante

Sur l'instantané initial, vérifier que la destination n'existe pas, y compris
comme lien cassé :

```bash
test ! -e "$HOME/.config/starship.toml" && test ! -L "$HOME/.config/starship.toml"
shasum -a 256 starship/.config/starship.toml
bash scripts/stow_setup.sh --dry-run
```

Choisir uniquement `starship`. Attendu : Stow effectue sa simulation, aucune
sauvegarde ni aucun lien ne sont créés, l'empreinte du fichier source reste
identique. L'absence de `.config` avant la simulation doit aussi être préservée.
Ne pas conclure à un succès si le script s'est arrêté faute de dépendance.
Si le premier `test` échoue, arrêter ce scénario et revenir à l'instantané
initial avant de continuer ; il ne s'agit plus du cas « destination absente ».

Puis, dans la VM seulement :

```bash
bash scripts/stow_setup.sh --apply
```

Choisir à nouveau `starship`, puis vérifier :

```bash
test -L "$HOME/.config/starship.toml"
cmp -s "$HOME/.config/starship.toml" starship/.config/starship.toml
readlink "$HOME/.config/starship.toml"
shasum -a 256 starship/.config/starship.toml
```

Attendu : le lien mène à cette copie du dépôt, les fichiers sont identiques et
la source n'a pas changé. Chaque commande `test` ou `cmp` doit retourner `0`.

Relancer `--apply` avec le même paquet. Attendu : le lien reste fonctionnel,
aucune nouvelle sauvegarde n'est créée. Pour examiner les sauvegardes :

```bash
find "$HOME/.config" -name 'starship.toml.backup.*' -print
```

## 4. Sauvegarde d'un fichier ordinaire

Restaurer l'instantané. Dans la VM, préparer un fichier distinct sans écraser
un fichier déjà présent :

```bash
mkdir -p "$HOME/.config"
if [ ! -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
    printf '%s\n' '# Ancienne configuration de validation' > "$HOME/.config/starship.toml"
fi
shasum -a 256 "$HOME/.config/starship.toml"
shasum -a 256 starship/.config/starship.toml
```

Lancer d'abord `--dry-run`, puis `--apply`, en choisissant `starship`.
Attendu : la simulation conserve l'ancien fichier ; l'application le déplace
vers le chemin de sauvegarde annoncé et crée le lien. Comparer l'empreinte de
**cette sauvegarde exacte** avec l'empreinte de l'ancien fichier notée avant
l'application. La source du dépôt doit rester inchangée.

Suivre ensuite [le retour arrière manuel](retour-arriere.md#annuler-une-application-réussie).
Attendu : l'ancien fichier ordinaire, avec son contenu original, retrouve sa
place ; il n'est plus un lien. Ne pas retirer tous les paquets si seul
`starship` a été appliqué.

## 5. Refus avant modification

Restaurer l'instantané avant **chacune** des lignes du tableau. Préparer le cas
uniquement dans la VM, noter les empreintes et liens concernés, puis lancer
`stow_setup.sh --dry-run` et `--apply` avec le paquet `starship`.

| État à préparer manuellement | Résultat attendu dans les deux modes |
| --- | --- |
| `.config` est un fichier ordinaire | Refus de la structure ; fichier conservé |
| `.config/starship.toml` est un dossier | Refus ; dossier et contenu conservés |
| `.config` est un lien vers un autre dossier contenant un `starship.toml` distinct | Refus du dossier symbolique ; aucun déplacement dans l'autre dossier |
| `.config/starship.toml` est un lien vers un autre fichier ou une cible absente | Refus ; lien et cible conservés |
| `.config` pointe vers le dossier `.config` d'un ancien clone Starship | Refus ; aucun fichier de l'ancien clone déplacé ou renommé |
| Un `.stowrc` existe dans le `HOME` de la VM ou à la racine du clone | Refus des options implicites ; `.stowrc` inchangé |

Attendu commun : code de sortie non nul, aucune nouvelle sauvegarde, aucun
nouveau lien, empreintes identiques avant/après. Un message d'erreur seul ne
suffit pas : vérifier réellement ces invariants.

Tester aussi une sélection de plusieurs paquets, avec un conflit sur le dernier
paquet sélectionné : aucun fichier du premier paquet ne doit avoir été déplacé.

## 6. Interruption et restauration automatique : validation distincte

Ces scénarios dépendent du moment exact de l'erreur. Une application qui échoue
pendant la préparation ne prouve pas que la restauration fonctionne.
Ce guide ne fournit ni faux outil Stow, ni option injectant une panne pendant
une application réelle.

Restaurer l'instantané et préparer un fichier ordinaire comme à l'étape 4.
Dans la VM uniquement, on peut afficher la progression détaillée :

```bash
bash -x scripts/stow_setup.sh --apply
```

Choisir `starship`. Si une interruption `Ctrl+C` est effectivement reçue **après
le déplacement du fichier et avant la fin de l'application**, vérifier :

- code de sortie non nul ;
- ancien fichier restauré avec la même empreinte ;
- aucun nouveau lien restant à sa place ;
- fichier source du dépôt inchangé ;
- autres liens corrects avant la tentative toujours présents.

Le déroulement peut être trop rapide pour intervenir à ce moment. Si la
commande est déjà terminée, ou si l'interruption précède le déplacement,
marquer ce scénario **non exercé**, sans annoncer la restauration comme validée.
Ne pas couper un disque ni tuer une application sur le Mac principal pour
provoquer un échec.

Si un échec réel survient pendant Stow ou pendant la vérification finale,
contrôler les mêmes invariants. Si une destination est occupée entre-temps,
le résultat attendu est son maintien et la conservation de la sauvegarde avec
un message de restauration manuelle, pas son écrasement.

Un arrêt `KILL` ou une coupure électrique ne déclenche pas la restauration
automatique. Le [guide de retour arrière](retour-arriere.md) reste nécessaire.
Tant que les scénarios après déplacement n'ont pas été réellement exercés,
la restauration automatique reste **non validée en fonctionnement**.

## 7. Autres paquets et applications

Après les scénarios de base, reprendre les essais de simulation, application,
idempotence et retour arrière pour les autres paquets dans la VM :

- Zsh : nouveau terminal, commandes standard et plugins, sans sourcer le fichier
  dans le terminal principal pendant la préparation du dépôt ;
- Ghostty, Herdr, Starship et Yazi : absence d'erreur de configuration et rendu
  attendu avec les versions réellement installées ;
- Lazygit : chemin avec espaces sous `Library/Application Support`, affichage
  clair/sombre, Delta puis rendu Git via `|` ;
- `gh` : tests de consultation uniquement, avec un compte prévu pour l'essai,
  sans copier ses identifiants dans le dépôt ;
- hook Git : validation dans un dépôt de travail jetable, selon le
  [guide de vérification](verification.md), jamais en activant les hooks du
  clone principal pour un simple essai.

Les scripts `terminal_setup.sh` et `yazi_setup.sh` doivent également être essayés
dans la VM avec leurs prérequis présents. Le menu Stow seul ne valide pas ces
deux parcours complets.

## 8. Consigner ce qui a été prouvé

Remplir ce tableau dans ses notes, sans remplacer un statut par une supposition :

| Scénario | Statut initial | Preuve à conserver |
| --- | --- | --- |
| Bilan statique | Non exécuté | Sortie et code de retour |
| Simulation sans écriture | Non exécuté | Comparaison de l'état avant/après |
| Application et idempotence | Non exécuté | Liens, empreintes et sauvegardes |
| Sauvegarde et retour arrière manuel | Non exécuté | Empreinte du fichier restauré |
| Conflits et liens externes | Non exécuté | Refus et invariants préservés |
| Interruption après déplacement | Non exercé | Moment observé, restauration vérifiée |
| Échec pendant/après Stow | Non exercé | Erreur réelle et restauration vérifiée |
| Applications et trois scripts de liaison | Non exécuté | Versions et résultats observés |

Le script statique ne remplit pas ce tableau et n'exécute aucun de ces essais
d'application. Avant une utilisation sur le Mac habituel, conserver aussi une
sauvegarde indépendante de ses configurations personnelles.
