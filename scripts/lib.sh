#!/usr/bin/env bash
# Fonctions communes aux scripts de liaison.
# Ce fichier est destiné à être sourcé, pas exécuté directement.

if [ -t 1 ]; then
    C_INFO=$'\033[36m'
    C_OK=$'\033[32m'
    C_WARN=$'\033[33m'
    C_ERR=$'\033[31m'
    C_RESET=$'\033[0m'
else
    C_INFO=""
    C_OK=""
    C_WARN=""
    C_ERR=""
    C_RESET=""
fi

DRY_RUN="${DRY_RUN:-1}"

log_info() {
    printf '%s[INFO]%s %s\n' "$C_INFO" "$C_RESET" "$*"
}

log_ok() {
    printf '%s[OK]%s %s\n' "$C_OK" "$C_RESET" "$*"
}

log_warn() {
    printf '%s[WARN]%s %s\n' "$C_WARN" "$C_RESET" "$*"
}

log_error() {
    printf '%s[ERREUR]%s %s\n' "$C_ERR" "$C_RESET" "$*" >&2
}

run() {
    if [ "$DRY_RUN" -eq 1 ]; then
        log_info "[SIMULATION] $*"
    else
        "$@"
    fi
}

require_commands() {
    local tool missing=0
    for tool in "$@"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            log_error "Outil requis absent : $tool. Installez-le manuellement avant de relancer."
            missing=1
        fi
    done
    [ "$missing" -eq 0 ]
}

# Les tableaux sont initialisés par deploy_packages, jamais lors du sourçage.
check_target_parents() {
    local package="$1" relative="$2" allow_owned="${3:-1}"
    local rest="$relative" component target="$TARGET_HOME" source="$REPO_DIR/$package"

    while [[ "$rest" == */* ]]; do
        component="${rest%%/*}"
        rest="${rest#*/}"
        target="$target/$component"
        source="$source/$component"
        if [ -L "$target" ]; then
            if [ "$allow_owned" -ne 1 ] || [ ! -d "$target" ] || [ ! "$target" -ef "$source" ]; then
                log_error "Dossier symbolique non autorisé : $target. Aucun fichier ne sera déplacé à travers ce lien."
                return 1
            fi
        elif [ -e "$target" ] && [ ! -d "$target" ]; then
            log_error "Un dossier attendu est occupé par un fichier : $target"
            return 1
        fi
    done
}

classify_target() {
    local package="$1" relative="$2" path="$TARGET_HOME/$2"
    local source="$REPO_DIR/$1/$2"
    check_target_parents "$package" "$relative" || return 1
    if [ -e "$path" ] && [ "$path" -ef "$source" ]; then
        CURRENT_STATE=owned
    elif [ -L "$path" ]; then
        log_error "Lien existant vers une autre cible (ou lien cassé) : $path"
        return 1
    elif [ -f "$path" ]; then
        CURRENT_STATE=backup
    elif [ -e "$path" ]; then
        log_error "La destination n'est pas un fichier ordinaire : $path"
        return 1
    else
        CURRENT_STATE=absent
    fi
}

plan_file() {
    local package="$1" relative="$2" index backup="" suffix=0
    for ((index=0; index<${#PLAN_REL[@]}; index++)); do
        if [ "${PLAN_REL[$index]}" = "$relative" ]; then
            if [ "${PLAN_PKG[$index]}" = "$package" ]; then
                return 0
            fi
            log_error "Plusieurs paquets visent la même destination : $relative"
            return 1
        fi
    done
    classify_target "$package" "$relative" || return 1
    if [ "$CURRENT_STATE" = backup ]; then
        backup="$TARGET_HOME/$relative.backup.$(date +%Y%m%d%H%M%S).$$"
        while [ -e "$backup" ] || [ -L "$backup" ]; do
            suffix=$((suffix + 1))
            backup="$TARGET_HOME/$relative.backup.$(date +%Y%m%d%H%M%S).$$.$suffix"
        done
    fi
    PLAN_PKG+=("$package")
    PLAN_REL+=("$relative")
    PLAN_STATE+=("$CURRENT_STATE")
    PLAN_BACKUP+=("$backup")
    PLAN_MOVED+=(0)
}

plan_tree() {
    local package="$1" relative="${2:-}" entry name child
    local directory="$REPO_DIR/$1${2:+/$2}"
    # Parcours sans suivre les liens et sans fichier temporaire.
    for entry in "$directory"/* "$directory"/.[!.]* "$directory"/..?*; do
        [ -e "$entry" ] || [ -L "$entry" ] || continue
        name="${entry##*/}"
        child="${relative:+$relative/}$name"
        if [ -z "$relative" ]; then
            case "$name" in
                README*|LICENSE*|COPYING*|.stow-local-ignore) continue ;;
                .config|Library|.zshrc) ;;
                *) log_error "Entrée de paquet non prise en charge : $entry"; return 1 ;;
            esac
        fi
        if [ -L "$entry" ]; then
            log_error "Lien symbolique dans le paquet source : $entry"
            return 1
        elif [ -d "$entry" ]; then
            plan_tree "$package" "$child" || return 1
        elif [ -f "$entry" ] && [ -r "$entry" ]; then
            plan_file "$package" "$child" || return 1
        else
            log_error "Source illisible ou non prise en charge : $entry"
            return 1
        fi
    done
}

rollback_deployment() {
    local index package relative path source backup failed=0
    log_warn "Application interrompue : restauration des fichiers sauvegardés."
    for ((index=${#PLAN_REL[@]}-1; index>=0; index--)); do
        [ "${PLAN_STATE[$index]}" != owned ] || continue
        if [ "${PLAN_MOVED[$index]}" -eq 0 ] && [ "$STOW_STARTED" -eq 0 ]; then
            continue
        fi
        package="${PLAN_PKG[$index]}"
        relative="${PLAN_REL[$index]}"
        path="$TARGET_HOME/$relative"
        source="$REPO_DIR/$package/$relative"
        backup="${PLAN_BACKUP[$index]}"
        # Ne jamais restaurer à travers un dossier symbolique apparu entre-temps.
        if ! check_target_parents "$package" "$relative" 0; then
            log_error "Restauration manuelle requise : $path ; sauvegarde : $backup"
            failed=1
            continue
        fi
        if [ "$STOW_STARTED" -eq 1 ] && [ -L "$path" ] && [ "$path" -ef "$source" ]; then
            if ! run unlink "$path"; then
                failed=1
                continue
            fi
        fi
        if [ -n "$backup" ] && [ "${PLAN_MOVED[$index]}" -eq 1 ] && { [ -e "$backup" ] || [ -L "$backup" ]; }; then
            if [ -e "$path" ] || [ -L "$path" ]; then
                log_error "Destination occupée : restauration refusée ; sauvegarde conservée : $backup"
                failed=1
            elif run mv -n "$backup" "$path" && [ ! -e "$backup" ] && [ ! -L "$backup" ]; then
                log_ok "Configuration restaurée : $path"
            else
                log_error "Restauration manuelle requise depuis : $backup"
                failed=1
            fi
        fi
    done
    return "$failed"
}

deployment_exit() {
    local status="$1"
    trap - EXIT
    # Laisser finir la restauration même si Ctrl+C est pressé une seconde fois.
    trap '' INT TERM
    if [ "${DEPLOY_ACTIVE:-0}" -eq 1 ]; then
        rollback_deployment || log_error "Certaines sauvegardes demandent une restauration manuelle."
        [ "$status" -ne 0 ] || status=1
    fi
    exit "$status"
}

deploy_packages() {
    local package index relative path
    require_commands stow || return 1
    TARGET_HOME="$(cd "${HOME:?Répertoire personnel absent}" && pwd -P)" || return 1
    case "$TARGET_HOME/" in
        /|"$REPO_DIR/"*) log_error "Répertoire cible non autorisé : $TARGET_HOME"; return 1 ;;
    esac
    # Un .stowrc pourrait activer --adopt lors de l'application réelle.
    # Refuser ces options implicites plutôt que risquer de modifier les sources.
    for path in "$HOME/.stowrc" "$REPO_DIR/.stowrc"; do
        if [ -e "$path" ] || [ -L "$path" ]; then
            log_error "Options Stow implicites détectées : $path. Utilisez un environnement sans .stowrc."
            return 1
        fi
    done
    PLAN_PKG=() PLAN_REL=() PLAN_STATE=() PLAN_BACKUP=() PLAN_MOVED=()
    for package in "$@"; do
        case "$package" in
            ''|.*|-*|*/*) log_error "Nom de paquet non autorisé : $package"; return 1 ;;
        esac
        if [ ! -d "$REPO_DIR/$package" ] || [ -L "$REPO_DIR/$package" ]; then
            log_error "Paquet absent ou symbolique : $package"
            return 1
        fi
        plan_tree "$package" || return 1
    done
    if [ "${#PLAN_REL[@]}" -eq 0 ]; then
        log_error "Aucun fichier de configuration à lier."
        return 1
    fi
    cd "$REPO_DIR" || return 1
    log_info "Vérification des conflits Stow, sans aucune écriture."
    # --adopt est réservé à cette simulation : les fichiers ordinaires seront
    # sauvegardés par notre code, jamais importés dans les sources du dépôt.
    stow --simulate --adopt --dir="$REPO_DIR" --target="$TARGET_HOME" --no-folding --stow "$@" || return 1

    # Recontrôler l'ensemble des chemins avant le premier déplacement.
    for ((index=0; index<${#PLAN_REL[@]}; index++)); do
        classify_target "${PLAN_PKG[$index]}" "${PLAN_REL[$index]}" || return 1
        if [ "$CURRENT_STATE" != "${PLAN_STATE[$index]}" ]; then
            log_error "La destination a changé pendant la préparation : ${PLAN_REL[$index]}"
            return 1
        fi
    done
    DEPLOY_ACTIVE=0
    STOW_STARTED=0
    if [ "$DRY_RUN" -eq 0 ]; then
        DEPLOY_ACTIVE=1
        trap 'deployment_exit $?' EXIT
        trap 'exit 130' INT
        trap 'exit 143' TERM
    fi
    for ((index=0; index<${#PLAN_REL[@]}; index++)); do
        [ "${PLAN_STATE[$index]}" = backup ] || continue
        relative="${PLAN_REL[$index]}"
        path="$TARGET_HOME/$relative"
        check_target_parents "${PLAN_PKG[$index]}" "$relative" 0 || return 1
        log_info "Sauvegarde : $path -> ${PLAN_BACKUP[$index]}"
        # Enregistrer l'intention avant mv pour couvrir une interruption juste après.
        PLAN_MOVED[$index]=1
        run mv -n "$path" "${PLAN_BACKUP[$index]}" || return 1
        if [ "$DRY_RUN" -eq 0 ] && { [ -e "$path" ] || [ -L "$path" ]; }; then
            log_error "Le déplacement a été refusé : $path"
            return 1
        fi
    done
    STOW_STARTED=1
    # --stow préserve les liens existants ; --restow les supprimerait d'abord.
    run stow --dir="$REPO_DIR" --target="$TARGET_HOME" --no-folding --stow "$@" || return 1
    if [ "$DRY_RUN" -eq 0 ]; then
        for ((index=0; index<${#PLAN_REL[@]}; index++)); do
            package="${PLAN_PKG[$index]}"
            relative="${PLAN_REL[$index]}"
            if [ ! "$TARGET_HOME/$relative" -ef "$REPO_DIR/$package/$relative" ]; then
                log_error "Lien attendu absent après application : $relative"
                return 1
            fi
        done
        DEPLOY_ACTIVE=0
        trap - EXIT INT TERM
    fi
}
