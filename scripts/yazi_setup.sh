#!/bin/bash

echo "🚀 Installation de Yazi et de sa configuration..."

# --- 0. Resolve repository location (GNU Stow package) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
REPO_DIR=""
if [ -n "$SCRIPT_DIR" ]; then
    REPO_DIR="$(dirname "$SCRIPT_DIR")"
fi

if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/yazi/.config/yazi" ]; then
    echo "❌ Paquet Stow 'yazi' introuvable. Lancez ce script depuis un clone du dépôt."
    exit 1
fi

# --- 1. Install Homebrew if not present ---
if ! command -v brew &> /dev/null; then
    echo "🍺 Homebrew absent. Installation de Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew déjà installé."
fi

# --- 2. Install Yazi and recommended preview tools ---
echo "📦 Installation de Yazi et des outils de prévisualisation..."
echo "   (ffmpeg, sevenzip, jq, poppler, fd, ripgrep, fzf, zoxide, resvg, imagemagick)"
brew install yazi ffmpeg sevenzip jq poppler fd ripgrep fzf zoxide resvg imagemagick stow

# --- 3. Link configuration with GNU Stow ---
echo "🔗 Liaison de ~/.config/yazi avec GNU Stow..."

# Move an existing file aside so Stow can create its symlink
backup_if_needed() {
    local path="$1"
    local link target target_dir backup

    if [ ! -e "$path" ] && [ ! -L "$path" ]; then
        return 0
    fi

    if [ -L "$path" ]; then
        link="$(readlink "$path")"
        case "$link" in
            /*) target="$link" ;;
            *)  target="$(dirname "$path")/$link" ;;
        esac
        if target_dir="$(cd "$(dirname "$target")" 2>/dev/null && pwd -P)"; then
            target="$target_dir/$(basename "$target")"
            case "$target" in
                "$REPO_DIR"/*) [ -e "$target" ] && return 0 ;;
            esac
        fi
    fi

    backup="${path}.backup.$(date +%Y%m%d%H%M%S)"
    mv "$path" "$backup"
    echo "   Fichier existant déplacé : $path -> $backup"
}

for file in yazi.toml keymap.toml theme.toml; do
    backup_if_needed "$HOME/.config/yazi/$file"
done

if ! command -v stow >/dev/null 2>&1; then
    echo "❌ GNU Stow introuvable. Installez-le avec 'brew install stow' puis relancez."
    exit 1
fi

stow --dir="$REPO_DIR" --target="$HOME" --restow --no-folding yazi
echo "   Paquet 'yazi' lié depuis $REPO_DIR"

echo "----------------------------------------------------"
echo "✅ INSTALLATION TERMINÉE !"
echo "----------------------------------------------------"
echo "1. Lancez Yazi avec la commande 'yazi'."
echo "2. Pour modifier la configuration, éditez '$REPO_DIR/yazi/.config/yazi/yazi.toml'."
echo "3. Touches utiles : '.' pour les fichiers cachés, 'z' pour fzf, 'Z' pour zoxide."
