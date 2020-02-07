# Personal Improvements to default zsh shell environment

# Set up zsh prompt to be username@hostname$
setopt PROMPT_SUBST
export PROMPT='%n@%m$ '
export RPROMPT='%(?..[%?] )'

# Set up autocomplete
autoload -U compinit
compinit

# Allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

# Add a few default directories to PATH
export PATH=$PATH:/sbin:~/bin:~/.local/bin/:~/.cabal/bin:~/.cargo/bin/:

# Add default git info
export GIT_COMMITTER_EMAIL="alexw91@gmail.com"
export GIT_AUTHOR_EMAIL="alexw91@gmail.com"
export GIT_COMMITTER_NAME="Alex Weibel"
export GIT_AUTHOR_NAME="Alex Weibel"

# Git Config
git config --global alias.undo-commit 'reset --soft HEAD^' #"git undo-commit" will now undo the last commit and leave files intact
git config --global color.ui true
git config --global core.pager 'less -R'

# One Character Shortcuts
alias c="clear"
alias f="find . -name"
alias g="grep --color=always"
function t () { tree "$@" | less }

# One Word Shortcuts
alias beep="echo -e \"\07\""
alias refresh="source ~/.zshrc"
alias ls="ls --color"
alias ll="ls -la"
alias llr="tree -fi"
alias less="less -R"
alias grep="grep --line-buffered"
alias symlink="ln -s"
alias printdate="date +\"%c\""

# Typos
alias gti="git"
alias gtis="gits"
alias cim="vim"
alias cd.="cd ."
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# git aliases
alias rebase="git rebase -i"
alias pull="git pull --rebase"
alias show="git show"
alias gits="pwd && git status"
alias gd="git diff"
alias gdc="git diff --cached"

# Grep Colors
alias grey-grep="GREP_COLOR='1;30' grep --color=always"
alias red-grep="GREP_COLOR='1;31' grep --color=always"
alias green-grep="GREP_COLOR='1;32' grep --color=always"
alias yellow-grep="GREP_COLOR='1;33' grep --color=always"
alias blue-grep="GREP_COLOR='1;34' grep --color=always"
alias magenta-grep="GREP_COLOR='1;35' grep --color=always"
alias cyan-grep="GREP_COLOR='1;36' grep --color=always"
alias white-grep="GREP_COLOR='1;37' grep --color=always"

function highlight () { grep --color=always -E "$1|$" "$@"; }
function red-highlight () { red-grep -E "$1|$" "$@"; }
function green-highlight () { green-grep -E "$1|$" "$@";}

# Calculator
function calc() {
    echo "$@" | bc --mathlib;
}

# Git Recursive Checkout
function grc() {
	for d in ./*/ ; do (cd "$d" && git checkout "$@"); done
}

function git_stash_show () {
	git stash show -p stash@{"$1"};
}

function git_stash_apply () {
	#apply a git stash by it's number in the list from "git stash list"
	git stash apply stash@{"$1"};
}

function git_undo_last_commit() {
        git reset --soft HEAD~1;
}

# Overwrites uncommitted local file changes to specific file
function git_overwrite() {
	git fetch;
	git checkout HEAD -- "$1";
}

# Always print current directory name and files in current directory after every cd command
function cd () {
	builtin cd "$@" && pwd && ls
}

# Set up zsh history
if [ -z "$HISTFILE" ]; then
    HISTFILE=$HOME/.zsh_history
fi

HISTSIZE=1000000
SAVEHIST=1000000

# Show history
case $HIST_STAMPS in
  "mm/dd/yyyy") alias history='fc -fl 1' ;;
  "dd.mm.yyyy") alias history='fc -El 1' ;;
  "yyyy-mm-dd") alias history='fc -il 1' ;;
  *) alias history='fc -l 1' ;;
esac

setopt append_history
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups # ignore duplication command history list
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history # share command history data
