#!/usr/bin/env bash
# Objectif : établir un bilan statique du dépôt et des outils disponibles.
# Prérequis : Bash 3.2 ; Zsh, Git, Ruby, Python 3.11+ et ShellCheck pour tous les contrôles.
# Options : --dry-run (défaut), --help. Aucune option d'application.
# Effets : lecture seule ; aucun script de liaison ni aucune application lancés.
# Retour arrière : sans objet, aucun fichier ni réglage modifié.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
DRY_RUN=1
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

SUCCES=0
ERREURS=0
INCOMPLETS=0

usage() {
    cat <<'EOF'
Usage : bash scripts/verifier-depot.sh [--dry-run|--help]

Contrôle réellement la syntaxe et lit les configurations, sans les appliquer.
Inventorie les outils sans les lancer. Aucune installation ni connexion réseau.
Les outils absents sont signalés ; les autres contrôles continuent.

Codes de sortie :
  0  Contrôles statiques demandés terminés, outils trouvés ; pas une certification.
  1  Au moins un contrôle a échoué.
  2  Bilan incomplet ou option non prise en charge.
EOF
}

verifier() {
    local titre="$1"
    shift
    log_info "$titre"
    if "$@"; then
        SUCCES=$((SUCCES + 1))
        log_ok "$titre"
    else
        ERREURS=$((ERREURS + 1))
        log_error "$titre"
    fi
}

incomplet() {
    INCOMPLETS=$((INCOMPLETS + 1))
    log_warn "$*"
}

verifier_syntaxe() {
    local fichier
    for fichier in "$SCRIPT_DIR"/*.sh "$REPO_DIR/.githooks/pre-commit"; do
        verifier "Syntaxe Bash : ${fichier#"$REPO_DIR/"}" /bin/bash -n "$fichier"
    done
    if command -v zsh >/dev/null 2>&1; then
        verifier 'Syntaxe Zsh' zsh -n "$REPO_DIR/zsh/.zshrc"
    else
        incomplet 'Zsh absent : syntaxe de .zshrc non contrôlée.'
    fi
    if command -v shellcheck >/dev/null 2>&1; then
        verifier 'Analyse ShellCheck' shellcheck "$SCRIPT_DIR"/*.sh "$REPO_DIR/.githooks/pre-commit"
    else
        incomplet 'ShellCheck absent : analyse approfondie non effectuée. Aucun outil installé.'
    fi
}

verifier_yaml() {
    ruby -r yaml -e '
        document = YAML.safe_load(File.read(ARGV.fetch(0)))
        abort "La configuration doit être un objet YAML." unless document.is_a?(Hash)
    ' "$REPO_DIR/lazygit/Library/Application Support/lazygit/config.yml"
}

verifier_toml() {
    python3 -B - "$REPO_DIR" <<'PY'
from pathlib import Path
import sys
import tomllib

racine = Path(sys.argv[1])
for chemin in (
    "herdr/.config/herdr/config.toml",
    "starship/.config/starship.toml",
    "yazi/.config/yazi/yazi.toml",
):
    with (racine / chemin).open("rb") as fichier:
        tomllib.load(fichier)
    print("TOML valide : " + chemin)
PY
}

verifier_configurations() {
    if command -v ruby >/dev/null 2>&1; then
        verifier 'Syntaxe YAML de Lazygit (sans validation du schéma applicatif)' verifier_yaml
    else
        incomplet 'Ruby absent : syntaxe YAML non contrôlée.'
    fi
    if command -v python3 >/dev/null 2>&1 && python3 -B -c 'import tomllib' >/dev/null 2>&1; then
        verifier 'Syntaxe des trois configurations TOML' verifier_toml
    else
        incomplet 'Python avec tomllib absent (Python 3.11+) : syntaxe TOML non contrôlée.'
    fi
    log_warn 'Configuration Ghostty et compatibilité des versions : hors du bilan statique, validation applicative manuelle requise.'
}

inventorier_outils() {
    local outil
    log_info 'Inventaire uniquement : aucune application ne sera lancée.'
    for outil in stow ghostty herdr nvim starship zoxide fzf eza bat yazi ffmpeg 7zz jq pdftoppm fd rg resvg magick; do
        if command -v "$outil" >/dev/null 2>&1; then
            log_ok "Outil trouvé : $outil"
        else
            incomplet "Outil absent du PATH : $outil. Nécessaire uniquement au parcours qui l'utilise."
        fi
    done
    for outil in lazygit delta gh; do
        if command -v "$outil" >/dev/null 2>&1; then
            log_ok "Complément trouvé : $outil"
        else
            log_warn "Complément facultatif absent du PATH : $outil"
        fi
    done
    for outil in zsh-autosuggestions zsh-syntax-highlighting; do
        if [ -r "$HOME/.zsh/$outil/$outil.zsh" ]; then
            log_ok "Plugin lisible : $outil (contenu non audité)"
        else
            incomplet "Plugin absent ou illisible : $outil ; requis par terminal_setup.sh."
        fi
    done
}

main() {
    local argument
    for argument in "$@"; do
        case "$argument" in
            --dry-run) ;;
            -h|--help) usage; return 0 ;;
            *) log_error "Option non prise en charge : $argument"; usage; return 2 ;;
        esac
    done
    cd "$REPO_DIR"
    verifier_syntaxe
    verifier_configurations
    if command -v git >/dev/null 2>&1; then
        verifier 'Espaces des modifications suivies par Git' env GIT_OPTIONAL_LOCKS=0 git -c core.fsmonitor=false --no-pager diff --no-ext-diff --no-textconv --check
    else
        incomplet 'Git absent : contrôle des espaces non effectué.'
    fi
    inventorier_outils
    log_info "Bilan : $SUCCES contrôles réussis, $ERREURS échecs, $INCOMPLETS points non vérifiés ou prérequis manquants."
    log_warn 'Aucune application, restauration ou interruption testée. Ce bilan ne certifie pas la sécurité du déploiement.'
    [ "$ERREURS" -eq 0 ] || return 1
    [ "$INCOMPLETS" -eq 0 ] || return 2
}

main "$@"
