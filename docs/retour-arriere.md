# Retour arrière manuel

Ces commandes sont des instructions à relire et à lancer soi-même sur la machine
cible. Elles n'ont pas été exécutées pendant le développement.

## Après une application échouée

Le script tente automatiquement de restaurer les fichiers déplacés si Stow
échoue, si la vérification finale échoue ou après une interruption `INT`/`TERM`.
Il ne supprime que les nouveaux liens pointant vers les sources attendues ;
les liens déjà corrects avant l'opération sont conservés.

Si une destination a été occupée ou si un dossier parent est devenu symbolique,
la restauration de ce chemin est refusée : lire le chemin de sauvegarde affiché
et examiner la situation avant toute action manuelle. Une interruption `KILL`
ou une coupure électrique peut empêcher la restauration automatique. Des dossiers
vides créés pendant la tentative peuvent subsister.

**Ne pas commencer par retirer tous les paquets après un échec** : cela
retirerait aussi des liens qui étaient corrects avant la tentative. Restaurer
uniquement les chemins signalés, comme expliqué aux étapes 2 à 4 ci-dessous.

## Annuler une application réussie

1. Depuis la racine du même clone, retirer uniquement les paquets appliqués :

```bash
stow --target="$HOME" --delete ghostty herdr starship yazi zsh
```

Ajouter `lazygit` si son paquet a été appliqué. Sa sauvegarde se trouve à côté
de `~/Library/Application Support/lazygit/config.yml` : conserver les guillemets
autour de ces chemins contenant des espaces.

2. Consulter les chemins de sauvegarde affichés pendant l'application. Les
   sauvegardes sont à côté des fichiers d'origine, avec le suffixe
   `.backup.HORODATAGE`, éventuellement suivi d'un numéro. Choisir la sauvegarde
   correspondant à l'état voulu ; ne pas toutes les restaurer successivement.
3. Vérifier que la destination n'existe plus, y compris comme lien symbolique.
   Si elle existe, s'arrêter et l'examiner avant tout remplacement.
4. Restaurer chaque sauvegarde en utilisant ses chemins exacts. Par exemple,
   remplacer la valeur ci-dessous par le véritable chemin affiché :

```bash
sauvegarde="$HOME/.zshrc.backup.HORODATAGE"
destination="$HOME/.zshrc"
if { [ -e "$sauvegarde" ] || [ -L "$sauvegarde" ]; } &&
   [ ! -e "$destination" ] && [ ! -L "$destination" ]; then
    mv -i "$sauvegarde" "$destination"
else
    printf '%s\n' 'Restauration non effectuée : vérifier les deux chemins.'
fi
```

Répéter avec les chemins exacts pour les configurations sous `~/.config`.
Les fichiers qui n'existaient pas avant application n'ont pas de sauvegarde :
le retrait du lien suffit. Les scripts n'installent aucun logiciel ; il n'y a
pas de désinstallation de dépendances à effectuer.

Après restauration, ouvrir une nouvelle session de terminal sur la machine cible.

Pour retirer l'automatisation avant commit, suivre la section de désactivation
du [guide de vérification](verification.md). Elle est indépendante des liens Stow.
