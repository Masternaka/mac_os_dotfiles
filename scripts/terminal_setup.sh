#!/bin/bash

echo "🚀 Starting the Ultimate macOS Terminal Setup Script..."

# --- 0. Resolve repository location (GNU Stow packages) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd -P || true)"
REPO_DIR=""
if [ -n "$SCRIPT_DIR" ]; then
    REPO_DIR="$(dirname "$SCRIPT_DIR")"
fi

if [ -z "$REPO_DIR" ] \
    || [ ! -d "$REPO_DIR/ghostty/.config/ghostty" ] \
    || [ ! -d "$REPO_DIR/herdr/.config/herdr" ] \
    || [ ! -d "$REPO_DIR/starship/.config" ]; then
    echo "❌ Stow packages not found. Run this script from a clone of the repository."
    exit 1
fi

# --- 1. Install Homebrew if not present ---
if ! command -v brew &> /dev/null; then
    echo "🍺 Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed."
fi

# --- 2. Install Core Tools & JetBrains Mono Nerd Font ---
echo "📦 Installing Ghostty, Herdr, Starship, Zoxide, fzf, eza, bat, GNU Stow..."
echo "Also installing the JetBrains Mono Nerd Font (via Homebrew Cask)."

brew install --cask ghostty
brew install --cask font-jetbrains-mono-nerd-font # Font used by the repo's Ghostty config

brew install herdr zoxide fzf eza bat starship stow

# --- 3. Setup Zsh Plugins (Autosuggestions & Syntax Highlighting) ---
echo "🔌 Setting up Zsh plugins: autosuggestions and syntax highlighting..."
mkdir -p ~/.zsh

# Zsh-autosuggestions
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
else
    echo "   zsh-autosuggestions already cloned. Updating..."
    (cd ~/.zsh/zsh-autosuggestions && git pull)
fi

# Zsh-syntax-highlighting
if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
else
    echo "   zsh-syntax-highlighting already cloned. Updating..."
    (cd ~/.zsh/zsh-syntax-highlighting && git pull)
fi

# --- 4. Write ~/.zshrc (Shell Configuration) ---
echo "📝 Creating/Updating ~/.zshrc configuration file..."
cat << 'EOF' > ~/.zshrc
# --- Environment Variables ---
export LANG=en_US.UTF-8
export EDITOR='nvim' # Or 'nano', 'code --wait', etc.

# --- Zsh Plugin Loading ---
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# --- Tool Initializations ---
eval "$(starship init zsh)" # Catppuccin Macchiato prompt
eval "$(zoxide init zsh)"   # Smart 'cd' command

# --- FZF Keybindings & Completion ---
# This line sources fzf's keybindings and completion setup
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- Modern CLI Aliases ---
# Replace old commands with their modern, feature-rich alternatives
alias ls='eza --icons --group-directories-first' # 'ls' with icons and better grouping
alias ll='eza -lh --icons --grid'                # 'ls -l' with icons and grid view
alias cat='bat'                                  # 'cat' with syntax highlighting and Git integration
alias cd='z'                                     # Make 'cd' use zoxide's smart jumping
alias g='git'                                    # Shorthand for Git
EOF

# --- 5. Link configuration files with GNU Stow ---
echo "🔗 Linking Ghostty, Herdr and Starship configs with GNU Stow..."

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
    echo "   Existing file moved: $path -> $backup"
}

backup_if_needed "$HOME/.config/ghostty/config"
backup_if_needed "$HOME/.config/herdr/config.toml"
backup_if_needed "$HOME/.config/starship.toml"

if ! command -v stow >/dev/null 2>&1; then
    echo "❌ GNU Stow not found. Install it with 'brew install stow' and re-run."
    exit 1
fi

stow --dir="$REPO_DIR" --target="$HOME" --restow --no-folding ghostty herdr starship
echo "   Linked ghostty, herdr and starship from $REPO_DIR"

echo "----------------------------------------------------"
echo "✅ SETUP COMPLETE!"
echo "----------------------------------------------------"
echo "Instructions for a perfect experience:"
echo "1. Open 'Ghostty' from your Applications folder. Its config is symlinked by GNU Stow."
echo "2. To customize Ghostty, Herdr or Starship, edit the files in '$REPO_DIR' (ghostty/, herdr/, starship/)."
echo "3. In Ghostty, type 'source ~/.zshrc' and press Enter to load your new Zsh config."
echo "4. Type 'herdr' and press Enter to start your persistent Herdr session."
echo "   Your modern terminal is now fully operational!"
echo "   ('z' for smart CD, Starship shows the Catppuccin Macchiato prompt, etc.)"