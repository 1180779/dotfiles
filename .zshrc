# ~/.zshrc: executed by zsh for interactive shells.

# ============================================================================
# Environment variables
# ============================================================================

export XDG_TERMINAL_EMULATOR=alacritty
export TERM=xterm-256color  # Prevent Alacritty from advertising kitty keyboard protocol support

# ============================================================================
# PATH
# ============================================================================

typeset -U PATH  # Keep PATH unique (no duplicates)

PATH="$HOME/.local/share/JetBrains/Toolbox/apps:$PATH"
PATH="$HOME/.local/bin:$PATH"
PATH="$HOME/.local/share/JetBrains/Toolbox/apps/rider/lib/ReSharperHost/linux-x64/dotnet:$PATH"

export PATH

# ============================================================================
# History configuration
# ============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=50000          # Lines kept in memory
SAVEHIST=50000          # Lines written to HISTFILE

setopt appendhistory         # Append to history file, don't overwrite
setopt sharehistory          # Share history across all sessions
setopt extendedhistory       # Save timestamps and duration
setopt histignorealldups     # Remove older duplicate entries
setopt histignorespace       # Don't save commands starting with space
setopt histverify            # Don't execute expanded history immediately
setopt incappendhistory      # Write to history file immediately, not on exit

# ============================================================================
# Basic options (bash shopt equivalents)
# ============================================================================

setopt autocd                # cd into directory by typing its name
setopt extendedglob          # Enable advanced globbing patterns
setopt nobeep                # Disable beep sounds
setopt interactivecomments   # Allow comments in interactive shell

# ============================================================================
# Color support
# ============================================================================

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ============================================================================
# Prompt
# ============================================================================

# Simple prompt equivalent to your bash one
# %n = username, %m = hostname, %~ = current directory, %# = # for root, % for user
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%# '

# If you want the debian_chroot functionality:
# if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
#     debian_chroot=$(cat /etc/debian_chroot)
#     PROMPT="${debian_chroot:+($debian_chroot)}%F{green}%n@%m%f:%F{blue}%~%f%# "
# fi

# ============================================================================
# Completions
# ============================================================================

autoload -Uz compinit && compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# ============================================================================
# lesspipe
# ============================================================================

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ============================================================================
# Aliases
# ============================================================================

if [ -f ~/.aliases ]; then
    source ~/.aliases
fi

# ============================================================================
# External tools
# ============================================================================

eval "$(mise activate zsh)"
source "$HOME/.cargo/env"

# Google Cloud SDK
if [ -f "$HOME/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/Downloads/google-cloud-cli-linux-x86_64/google-cloud-sdk/completion.zsh.inc"
fi

# ============================================================================
# Custom functions
# ============================================================================

tagsum() {
    if [ $# -eq 0 ]; then
        command timew tagsum :week
    else
        command timew tagsum "$@"
    fi
}
alias tagweek='TAGSUM_MODE=grouped timew tagsum :week'

alias vim="nvim"

# ----------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="custom" #"robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh
