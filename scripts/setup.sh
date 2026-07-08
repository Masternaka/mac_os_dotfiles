#!/bin/bash

echo "🚀 Starting the Ultimate macOS Terminal Setup Script..."

# --- 1. Install Homebrew if not present ---
if ! command -v brew &> /dev/null; then
    echo "🍺 Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed."
fi

# --- 2. Install Core Tools & Anka/Coder Font ---
echo "📦 Installing Ghostty, Tmux, Atuin, Starship, Zoxide, fzf, eza, bat..."
echo "Also installing the Anka/Coder font (via Homebrew Cask)."

brew install --cask ghostty
brew install --cask font-anka-coder # The "Anker Coder" font

brew install tmux atuin zoxide fzf eza bat starship

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
eval "$(starship init zsh)" # Minimalist, fast prompt
eval "$(zoxide init zsh)"   # Smart 'cd' command
eval "$(atuin init zsh)"    # Searchable shell history

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

# --- Custom Key Bindings ---
# Use Up-Arrow for Atuin's full-screen history search
bindkey '^[[A' atuin-up-search
EOF

# --- 5. Write Ghostty Configuration ---
echo "👻 Creating ~/.config/ghostty/config file..."
mkdir -p ~/.config/ghostty
cat << EOF > ~/.config/ghostty/config
# Theme and Appearance
theme = dark-plus
font-family = "Anka/Coder" # Using the installed Anka/Coder font
font-size = 14
background-opacity = 0.9
background-blur = true

# macOS Integration
macos-titlebar-style = hidden
window-save-state = "always" # Ensure sessions persist across Ghostty restarts
EOF

# --- 6. Write Tmux Configuration & Install TPM (Tmux Plugin Manager) ---
echo "🪟 Creating ~/.tmux.conf file and installing Tmux Plugin Manager (TPM)..."
mkdir -p ~/.tmux/plugins

# Clone TPM if it doesn't exist
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
    echo "   TPM already cloned. Updating..."
    (cd ~/.tmux/plugins/tpm && git pull)
fi

cat << 'EOF' > ~/.tmux.conf
# --- General Tmux Settings ---
set -g default-terminal "screen-256color" # Enable 256 colors
set -g mouse on                           # Enable mouse support for resizing panes, scrolling
set -s escape-time 0                      # Reduce escape key delay (important for Vim users)
set -g history-limit 10000                # Increase scrollback buffer

# --- Custom Key Bindings for Panes ---
# Split panes horizontally and vertically using intuitive | and - keys
bind | split-window -h -c "#{pane_current_path}" # Split vertical
bind - split-window -v -c "#{pane_current_path}" # Split horizontal
unbind '"'                                       # Unbind default split keys
unbind %

# --- Pane Navigation with Alt + Arrow Keys ---
# This allows quick pane switching without the Tmux prefix key (Ctrl+b)
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# --- Status Bar Styling (Optional: For a cleaner look) ---
set -g status-style bg=default
set -g status-left-length 40
set -g status-left "#[fg=green]Session: #S #[fg=yellow]• " # Session name
set -g status-right "#[fg=cyan]%H:%M #[fg=magenta]%d-%b-%y" # Time and date

# --- Tmux Plugin Manager (TPM) & Plugins ---
# List of plugins to be installed by TPM
set -g @plugin 'tmux-plugins/tpm'           # Tmux Plugin Manager itself
set -g @plugin 'tmux-plugins/tmux-resurrect' # Save and restore Tmux environment
set -g @plugin 'tmux-plugins/tmux-continuum' # Continuously save Tmux environment

# Configure tmux-continuum to automatically restore sessions on Tmux start
set -g @continuum-restore 'on'

# Initialize TPM. This line MUST be at the very end of .tmux.conf
run '~/.tmux/plugins/tpm/tpm'
EOF

# --- Automated Tmux Plugin Installation ---
echo "⚙️  Automatically installing Tmux plugins (no manual keypress needed)..."
~/.tmux/plugins/tpm/bin/install_plugins

echo "----------------------------------------------------"
echo "✅ SETUP COMPLETE!"
echo "----------------------------------------------------"
echo "Instructions for a perfect experience:"
echo "1. Open 'Ghostty' from your Applications folder. (It should pick up the config automatically)."
echo "2. In Ghostty, type 'source ~/.zshrc' and press Enter to load your new Zsh config."
echo "3. Type 'tmux' and press Enter to start your persistent Tmux session."
echo "   Your modern terminal is now fully operational!"
echo "   (Press Up-Arrow to try Atuin's history search, 'z' for smart CD, etc.)"