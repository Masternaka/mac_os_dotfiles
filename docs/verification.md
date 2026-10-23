# Vérifications manuelles

Ces contrôles lisent le code sans appliquer les configurations. Ils sont
destinés à être lancés manuellement depuis la racine du dépôt.

## Bilan en une commande

```bash
bash scripts/verifier-depot.sh --dry-run
```

Le script ne modifie rien et ne lance pas les applications. Il continue après
un contrôle indisponible ou un échec, puis renvoie `1` pour un échec ou `2` pour
un bilan incomplet ; `0` signifie seulement que les contrôles statiques prévus
ont pu être terminés. Le [guide avant application](validation-avant-application.md)
explique les prérequis, les limites et les essais manuels dans un macOS jetable.

## Syntaxe sans dépendance supplémentaire

```bash
for script in scripts/*.sh; do
    bash -n "$script" || break
done
zsh -n zsh/.zshrc
git diff --check
```

`bash -n` analyse un fichier à la fois ; passer plusieurs chemins à une seule
invocation ne contrôle pas tous les fichiers.

## ShellCheck

[ShellCheck](https://github.com/koalaman/shellcheck) complète l'analyse syntaxique
des scripts Bash avec des diagnostics sur les variables, les guillemets et les
cas limites. Il doit déjà être présent ; aucun script ne l'installe.

```bash
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck scripts/*.sh
else
    printf '%s\n' 'ShellCheck absent : utiliser les contrôles de syntaxe ci-dessus.'
fi
```

Le fichier `.shellcheckrc` autorise l'analyse de `scripts/lib.sh` et résout
les chemins sourcés relativement au script. Aucun diagnostic n'est désactivé.
ShellCheck ne prend pas en charge Zsh : `.zshrc` est contrôlé par `zsh -n`.

Pour inclure le hook livré dans l'analyse manuelle :

```bash
bash -n .githooks/pre-commit
shellcheck scripts/*.sh .githooks/pre-commit
```

## Contrôle avant commit facultatif

Le fichier `.githooks/pre-commit` automatise ces vérifications pour les commits
de **ce dépôt seulement**, dans le terminal comme dans Lazygit. Il exige Git,
Bash, Zsh et ShellCheck déjà présents. Si un outil manque, le commit est bloqué
avec un message explicite. Aucun outil n'est téléchargé ou installé.

Pour garder le contrôle simple et fiable, les fichiers analysés doivent être
entièrement indexés : scripts Bash, hook, `.shellcheckrc` et `.zshrc`. Le hook
refuse de continuer si leur version de travail diffère de l'index, ou si un de
ces fichiers n'y figure pas encore. Les autres fichiers peuvent être indexés
partiellement. Il ne lance aucun script de liaison et ne reformate rien.

Avant activation, consulter les réglages et hooks existants :

```bash
git config --show-origin --get core.hooksPath
git rev-parse --git-path hooks/pre-commit
```

La première commande ne produit rien et renvoie le code 1 en l'absence de
réglage. Si un chemin est configuré, ou si le chemin retourné par la seconde
commande contient déjà un hook actif, s'arrêter et prévoir une intégration
manuelle : ne pas remplacer les hooks existants.

Après relecture, **sur la machine cible**, rendre le hook exécutable et activer
ce dossier pour ce clone uniquement :

```bash
chmod +x .githooks/pre-commit
git config --local core.hooksPath .githooks
```

Ces commandes ne sont pas exécutées par les scripts du dépôt. Pour contrôler
manuellement les fichiers entièrement indexés sans créer de commit :

```bash
bash .githooks/pre-commit --dry-run
```

Le hook est toujours en lecture seule : `--apply` effectue les mêmes contrôles,
sans aucune modification. Un échec bloque le commit, il ne le répare pas.

Pour désactiver l'automatisation, vérifier d'abord que la valeur locale est bien
`.githooks`, puis retirer uniquement ce réglage ajouté lors de l'activation :

```bash
git config --local --get core.hooksPath
git config --local --unset core.hooksPath
```

Ne pas retirer une autre valeur. Aucun hook n'est copié dans `.git/hooks`, aucun
réglage global n'est modifié. Les hooks Git sont un confort local contournable
par l'utilisateur, pas une garantie imposée à tous les contributeurs.

Références : [hooks Git](https://git-scm.com/docs/githooks) et
[directives ShellCheck](https://www.shellcheck.net/wiki/Directive).

Une analyse statique réussie ne prouve pas le comportement de Stow, le rendu de
Lazygit/Delta ni la compatibilité de toutes les versions des applications.
Les essais d'application se font manuellement dans un environnement jetable.
