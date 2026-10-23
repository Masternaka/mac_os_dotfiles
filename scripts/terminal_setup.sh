#!/usr/bin/env bash
# Objectif : vérifier les outils et lier Ghostty, Herdr, Starship et Zsh.
# Prérequis : outils et plugins décrits dans scripts/README.md, déjà présents.
# Options : --dry-run (défaut), --apply, --help.
# Effets : sauvegarde des configurations existantes et création des liens Stow.
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
Usage : terminal_setup.sh [options]

Vérifie les outils du terminal et relie les configurations du dépôt avec GNU Stow.

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
    local package

    if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR" ]; then
        log_error "Dépôt introuvable. Lancez ce script depuis un clone du dépôt."
        exit 1
    fi

    for package in ghostty herdr starship; do
        if [ ! -d "$REPO_DIR/$package/.config" ]; then
            log_error "Paquet Stow '$package' introuvable dans $REPO_DIR."
            exit 1
        fi
    done

    if [ ! -f "$REPO_DIR/zsh/.zshrc" ]; then
        log_error "Paquet Stow 'zsh' introuvable dans $REPO_DIR."
        exit 1
    fi
}

check_dependencies() {
    require_commands stow ghostty herdr nvim starship zoxide fzf eza bat
    local plugin
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [ ! -r "$HOME/.zsh/$plugin/$plugin.zsh" ]; then
            log_error "Plugin requis absent : $HOME/.zsh/$plugin/$plugin.zsh. Préparez-le manuellement."
            return 1
        fi
    done
}

link_configs() {
    log_info "Sauvegarde des configurations existantes puis liaison avec GNU Stow."

    deploy_packages ghostty herdr starship zsh
}

summary() {
    if [ "$DRY_RUN" -eq 1 ]; then
        log_warn "Mode simulation : aucune modification n'a été effectuée."
        log_info "Relancez avec --apply pour appliquer les changements."
        return 0
    fi

    log_ok "Configurations liées."
    log_info "Ouvrez Ghostty, puis lancez 'source ~/.zshrc' ou redémarrez le terminal."
    log_info "Lancez 'herdr' pour démarrer Herdr."
}

main() {
    parse_args "$@"
    check_repo
    check_dependencies
    link_configs
    summary
}

main "$@"
