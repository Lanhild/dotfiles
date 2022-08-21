#! /bin/zsh
typeset -A _kyoto
_kyoto="$HOME/.zsh"
SHELL=$(which zsh || echo '/bin/zsh')

# Remove useless sounds
unsetopt BEEP

# Options
autoload -U colors && colors
export CLICOLOR=1
unsetopt nomatch
setopt interactivecomments

# Prompt path
fpath=(
    ~/.zsh/prompt/
    $fpath)

# History managing
HISTFILE=$HOME/.zsh_history       # enable history saving on shell exit
setopt SHARE_HISTORY           # share history between sessions
HISTSIZE=10000                  # lines of history to maintain memory
SAVEHIST=1000                  # lines of history to maintain in history file.
setopt HIST_EXPIRE_DUPS_FIRST  # allow dups, but expire old ones when I hit HISTSIZE
setopt EXTENDED_HISTORY        # save timestamp and runtime information

# Adds case insensitivity
zstyle ':completion:*' completer _complete
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
# Color completion folders
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==34=34}:${(s.:.)LS_COLORS}")';
# Kill colors
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
# Option colors
zstyle ':completion:*:options' list-colors '=^(-- *)=34'
# Highlights current option
zstyle ':completion:*' menu select

autoload -Uz compinit
compinit -i

# Nice auto correct prompt
autoload -U colors && colors
export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r?$reset_color (Yes, No, Abort, Edit) "

# Colorify man
function man() {
    env \
	LESS_TERMCAP_mb=$(printf "\e[1;31m") \
	LESS_TERMCAP_md=$(printf "\e[1;31m") \
	LESS_TERMCAP_me=$(printf "\e[0m") \
	LESS_TERMCAP_se=$(printf "\e[0m") \
	LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
	LESS_TERMCAP_ue=$(printf "\e[0m") \
	LESS_TERMCAP_us=$(printf "\e[1;32m") \
	man "$@"
}

# Tweaks
fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-Z
bindkey '^Z' fancy-ctrl-z

# Keybinds
bindkey '^P' up-history
bindkey '^N' down-history

# backspace and ^h working even after
# returning from command mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char

# ctrl-w removed word backwards
bindkey '^w' backward-kill-word
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

# ctrl-r starts searching history backward
bindkey '^r' history-incremental-search-backward

# VI MODE KEYBINDINGS (ins mode)
bindkey -M viins '^a'    beginning-of-line
bindkey -M viins '^e'    end-of-line
bindkey -M viins '^k'    kill-line
bindkey -M viins '^w'    backward-kill-word
bindkey -M viins '^u'    backward-kill-line
zle -N edit-command-line
bindkey -M viins '^xe'  edit-command-line
bindkey -M viins '^x^e'  edit-command-line

# Aliases definition
alias grep='grep --color=always'
alias lsa='ls -lah --color'
alias l='ls --color'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Prompt
_newline=$'\n'
_lineup=$'\e[1A'
_linedown=$'\e[1B'

function preexec {
    echo
}
function precmd {
    echo
}

function promptjobs {
    jobs %% 2> /dev/null | cut -d " " -f6
}

PROMPT="%F{red}%n%F{white}@%F{green}%m %F{blue}%~ ${_newline}%F{white}$ "
RPROMPT='%{${_lineup}%}%F{red}%(?..%? )%F{yellow}%v%F{white}$(promptjobs) [`date +%H:%M:%S`]%{${_linedown}%}'
setopt promptsubst

# Small delay
export KEYTIMEOUT=1

source $_kyoto/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source $_kyoto/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

setopt correct
setopt autocd              # change directory just by typing its name
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt MENU_COMPLETE        # Automatically highlight first element of completion menu
setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
setopt COMPLETE_IN_WORD     # Complete from both ends of a word.

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#484E5B,underline"

# End
cat ~/.cache/wal/sequences
$_kyoto/bin/fetchtool
