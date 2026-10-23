#!/bin/bash

echo "🚀 Installation de GNU Stow (les liens sont optionnels)..."

# --- 0. Resolve repository location ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
REPO_DIR=""
if [ -n "$SCRIPT_DIR" ]; then
    REPO_DIR="$(dirname "$SCRIPT_DIR")"
fi

if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR" ]; then
    echo "❌ Dépôt introuvable. Lancez ce script depuis un clone du dépôt."
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

# --- 2. Install GNU Stow ---
echo "📦 Installation de GNU Stow..."
brew install stow

# --- 3. Detect Stow packages in the repository ---
packages=()
for dir in "$REPO_DIR"/*/; do
    name="$(basename "$dir")"
    if [ -d "$dir/.config" ]; then
        packages+=("$name")
    fi
done

if [ ${#packages[@]} -eq 0 ]; then
    echo "❌ Aucun paquet Stow trouvé dans $REPO_DIR."
    exit 1
fi

# --- 4. Interactive package selection (none by default) ---
if [ ! -t 0 ]; then
    echo "Entrée non interactive : aucun lien ne sera créé."
    exit 0
fi

echo ""
echo "Paquets Stow disponibles :"
index=1
for name in "${packages[@]}"; do
    echo "  $index) $name"
    index=$((index + 1))
done
echo "  0) Aucun (par défaut)"

selected=()
while true; do
    printf 'Votre choix (numéros séparés par des espaces, 0 = aucun) [0] : '
    read -r selection
    selection="${selection:-0}"

    if [ "$selection" = "0" ]; then
        selected=()
        break
    fi

    valid=1
    selected=()
    for choice in $selection; do
        case "$choice" in
            *[!0-9]*)
                valid=0
                break
                ;;
        esac
        if [ "$choice" -ge 1 ] && [ "$choice" -le "${#packages[@]}" ]; then
            selected+=("${packages[$((choice - 1))]}")
        else
            valid=0
            break
        fi
    done

    if [ "$valid" -eq 1 ]; then
        break
    fi
    echo "Choix invalide. Entrez des numéros entre 1 et ${#packages[@]}, ou 0 pour aucun."
done

if [ ${#selected[@]} -eq 0 ]; then
    echo "Aucun lien créé (choix par défaut)."
    exit 0
fi

# --- 5. Move existing files of the selected packages aside ---
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

for name in "${selected[@]}"; do
    while IFS= read -r -d '' file; do
        relative="${file#"$REPO_DIR/$name/"}"
        backup_if_needed "$HOME/$relative"
    done < <(find "$REPO_DIR/$name/.config" -type f -print0)
done

# --- 6. Stow the selected packages ---
if ! command -v stow >/dev/null 2>&1; then
    echo "❌ GNU Stow introuvable. Installez-le avec 'brew install stow' puis relancez."
    exit 1
fi

stow --dir="$REPO_DIR" --target="$HOME" --restow --no-folding "${selected[@]}"
echo "   Paquets liés : ${selected[*]}"

echo "----------------------------------------------------"
echo "✅ GNU STOW EST PRÊT !"
echo "----------------------------------------------------"
echo "Configurations liées : ${selected[*]}"
echo "Vous pouvez maintenant lancer 'scripts/terminal_setup.sh' et 'scripts/yazi_setup.sh',"
echo "ou gérer les liens manuellement avec 'stow'."
