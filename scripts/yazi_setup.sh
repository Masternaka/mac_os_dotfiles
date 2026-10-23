#!/usr/bin/env bash
# Objectif : vérifier les outils de Yazi et lier sa configuration.
# Prérequis : outils décrits dans scripts/README.md, déjà présents.
# Options : --dry-run (défaut), --apply, --help.
# Effets : sauvegarde de la configuration existante et création des liens Stow.
# Retour arrière : voir docs/retour-arriere.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
REPO_DIR=""
if [ -n "$SCRIPT_DIR" ]; then
    REPO_DIR="$(dirname "$SCRIPT_DIR")"
fi

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/lib.sh" ]; then
    echo "Erreur : lib.sh introuvable." >&2
    exit 1
fi

DRY_RUN=1
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

usage() {
    cat <<'EOF'
Usage : yazi_setup.sh [options]

Vérifie Yazi, ses outils de prévisualisation et relie sa configuration avec GNU Stow.

Options :
  --dry-run   Affiche les actions sans rien modifier (défaut)
  --apply     Applique réellement les changements
  -h, --help  Affiche cette aide
EOF
}

parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --dry-run) DRY_RUN=1 ;;
            --apply)   DRY_RUN=0 ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "Option inconnue : $arg"
                usage
                exit 2
                ;;
        esac
    done
}

check_repo() {
    if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/yazi/.config/yazi" ]; then
        log_error "Paquet Stow 'yazi' introuvable. Lancez ce script depuis un clone du dépôt."
        exit 1
    fi
}

check_dependencies() {
    require_commands stow yazi ffmpeg 7zz jq pdftoppm fd rg fzf zoxide resvg magick
}

link_config() {
    deploy_packages yazi
}

summary() {
    if [ "$DRY_RUN" -eq 1 ]; then
        log_warn "Mode simulation : aucune modification n'a été effectuée."
        log_info "Relancez avec --apply pour appliquer les changements."
        return 0
    fi

    log_ok "Configuration Yazi liée."
    log_info "Lancez Yazi avec 'yazi'."
    log_info "Touches utiles : '.' pour les fichiers cachés, 'z' pour fzf, 'Z' pour zoxide."
}

main() {
    parse_args "$@"
    check_repo
    check_dependencies
    link_config
    summary
}

main "$@"
