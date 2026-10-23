# Configuration Zsh — destinée à ~/.zshrc (via GNU Stow)

# --- Homebrew (Apple Silicon ou Intel) ---
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

# --- Variables d'environnement ---
export LANG=en_US.UTF-8
if command -v nvim >/dev/null 2>&1; then
    export EDITOR='nvim'
fi

# --- Complétion ---
autoload -Uz compinit
compinit

# --- Plugins Zsh ---
if [[ -r "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# --- Initialisations des outils ---
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh --cmd cd)"
fi
# Les anciennes versions de fzf ne proposent pas --zsh.
if command -v fzf >/dev/null 2>&1; then
    if _fzf_initialisation="$(fzf --zsh 2>/dev/null)"; then
        eval "$_fzf_initialisation"
    fi
    unset _fzf_initialisation
fi

# --- Alias CLI modernes ---
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -lh --icons --grid'
fi
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi
alias g='git'

# --- Coloration syntaxique (doit rester en dernier) ---
if [[ -r "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
