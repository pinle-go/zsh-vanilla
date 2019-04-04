######################################## Extra ########################################
alias l="exa"
alias ls="exa"
alias ll="exa -l"
alias la="exa -la"

auto-ls () {
  if [[ $#BUFFER -eq 0 ]]; then
    zle && echo ""
    ls
    
    zle && zle redisplay
  else
    zle .$WIDGET
  fi
}

zle -N auto-ls
zle -N accept-line auto-ls
# chpwd_functions+=(auto-ls)

setopt PROMPT_SUBST
#RPROMPT=''
PROMPT='%F{yellow}%m%f %F{red}`shrink_path -t -f`%f $ '
######################################## Aliases ########################################
alias h="history"
alias hg="history -1000 | grep -i"
alias ,="cd .."
alias m="less"

alias ga="git add"
alias gb="git branch"
alias gc="git commit"
alias gd="git diff"
alias gt="git pull" # tirez
alias gp="git push" # pousser
alias gl="git log --graph --pretty=oneline --abbrev-commit"
alias gg="git status"
alias gco="git checkout"
alias gcl="git clone"

alias pcsv="column -s, -t | less -#2 -N -S"

pawk(){
    fields="$(sed -E 's/(^|,)/ \1\$/g'<<<"$1")"
    shift
    awk "{print $fields}" "$@"
}

######################################## History settings ########################################
HISTFILE=~/.history-zsh
HISTSIZE=10000
SAVEHIST=10000
setopt append_history           # allow multiple sessions to append to one history
setopt bang_hist                # treat ! special during command expansion
setopt extended_history         # Write history in :start:elasped;command format
setopt hist_expire_dups_first   # expire duplicates first when trimming history
setopt hist_find_no_dups        # When searching history, don't repeat
setopt hist_ignore_dups         # ignore duplicate entries of previous events
setopt hist_ignore_space        # prefix command with a space to skip it's recording
setopt hist_reduce_blanks       # Remove extra blanks from each command added to history
setopt hist_verify              # Don't execute immediately upon history expansion
setopt inc_append_history       # Write to history file immediately, not when shell quits
setopt share_history            # Share history among all sessions
# Tab completion
autoload -Uz compinit && compinit
setopt complete_in_word         # cd /ho/sco/tm<TAB> expands to /home/scott/tmp
setopt auto_menu                # show completion menu on succesive tab presses
setopt autocd                   # cd to a folder just by typing it's name
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&' # These "eat" the auto prior space after a tab complete
# MISC
setopt interactive_comments     # allow # comments in shell; good for copy/paste
unsetopt correct_all            # I don't care for 'suggestions' from ZSH
export BLOCK_SIZE="'1"          # Add commas to file sizes
# PATH
typeset -U path                 # keep duplicates out of the path
path+=(.)                       # append current directory to path (controversial)

######################################## Key bindings ########################################
# Make sure that the terminal is in application mode when zle is active, since
# only then values from $terminfo are valid
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
  function zle-line-init() {
    echoti smkx
  }
  function zle-line-finish() {
    echoti rmkx
  }
  zle -N zle-line-init
  zle -N zle-line-finish
fi
bindkey -e                                            # Use emacs key bindings
bindkey '\ew' kill-region                             # [Esc-w] - Kill from the cursor to the mark
bindkey -s '\el' 'ls\n'                               # [Esc-l] - run command: ls
bindkey '^r' history-incremental-search-backward      # [Ctrl-r] - Search backward incrementally for a specified string. The string may begin with ^ to anchor the search to the beginning of the line.
if [[ "${terminfo[kpp]}" != "" ]]; then
  bindkey "${terminfo[kpp]}" up-line-or-history       # [PageUp] - Up a line of history
fi
if [[ "${terminfo[knp]}" != "" ]]; then
  bindkey "${terminfo[knp]}" down-line-or-history     # [PageDown] - Down a line of history
fi
# start typing + [Up-Arrow] - fuzzy find history forward
if [[ "${terminfo[kcuu1]}" != "" ]]; then
  autoload -U up-line-or-beginning-search
  zle -N up-line-or-beginning-search
  bindkey "${terminfo[kcuu1]}" up-line-or-beginning-search
fi
# start typing + [Down-Arrow] - fuzzy find history backward
if [[ "${terminfo[kcud1]}" != "" ]]; then
  autoload -U down-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey "${terminfo[kcud1]}" down-line-or-beginning-search
fi
if [[ "${terminfo[khome]}" != "" ]]; then
  bindkey "${terminfo[khome]}" beginning-of-line      # [Home] - Go to beginning of line
fi
if [[ "${terminfo[kend]}" != "" ]]; then
  bindkey "${terminfo[kend]}"  end-of-line            # [End] - Go to end of line
fi
bindkey ' ' magic-space                               # [Space] - do history expansion
bindkey '^[[1;5C' forward-word                        # [Ctrl-RightArrow] - move forward one word
bindkey '^[[1;5D' backward-word                       # [Ctrl-LeftArrow] - move backward one word
if [[ "${terminfo[kcbt]}" != "" ]]; then
  bindkey "${terminfo[kcbt]}" reverse-menu-complete   # [Shift-Tab] - move through the completion menu backwards
fi
bindkey '^?' backward-delete-char                     # [Backspace] - delete backward
if [[ "${terminfo[kdch1]}" != "" ]]; then
  bindkey "${terminfo[kdch1]}" delete-char            # [Delete] - delete forward
else
  bindkey "^[[3~" delete-char
  bindkey "^[3;5~" delete-char
  bindkey "\e[3~" delete-char
fi
autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line
bindkey "^[m" copy-prev-shell-word


######################################## Completions ########################################
# fixme - the load process here seems a bit bizarre
zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

# should this be in keybindings?
bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=* r:|=*'
else
  if [[ "$HYPHEN_INSENSITIVE" = true ]]; then
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
  else
    zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
  fi
fi
unset CASE_SENSITIVE HYPHEN_INSENSITIVE

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
fi

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

if [[ $COMPLETION_WAITING_DOTS = true ]]; then
  expand-or-complete-with-dots() {
    # toggle line-wrapping off and back on again
    [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
    print -Pn "%{%F{red}......%f%}"
    [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam

    zle expand-or-complete
    zle redisplay
  }
  zle -N expand-or-complete-with-dots
  bindkey "^I" expand-or-complete-with-dots
fi

######################################## Shrink Path ########################################


# Shrink directory paths, e.g. /home/me/foo/bar/quux -> ~/f/b/quux.
#
# For a fish-style working directory in your command prompt, add the following
# to your theme or zshrc:
#
#   setopt prompt_subst
#   PS1='%n@%m $(shrink_path -f)>'
#
# The following options are available:
#
#   -f, --fish       fish simulation, equivalent to -l -s -t.
#   -l, --last       Print the last directory's full name.
#   -s, --short      Truncate directory names to the first character. Without
#                    -s, names are truncated without making them ambiguous.
#   -t, --tilde      Substitute ~ for the home directory.
#   -T, --nameddirs  Substitute named directories as well.
#
# The long options can also be set via zstyle, like
#   zstyle :prompt:shrink_path fish yes
#
# Note: Directory names containing two or more consecutive spaces are not yet
# supported.
#
# Keywords: prompt directory truncate shrink collapse fish
#
# Copyright (C) 2008 by Daniel Friesel <derf@xxxxxxxxxxxxxxxxxx>
# License: WTFPL <http://www.wtfpl.net>
#
# Ref: https://www.zsh.org/mla/workers/2009/msg00415.html
#      https://www.zsh.org/mla/workers/2009/msg00419.html

shrink_path () {
        setopt localoptions
        setopt rc_quotes null_glob

        typeset -i lastfull=0
        typeset -i short=0
        typeset -i tilde=0
        typeset -i named=0

        if zstyle -t ':prompt:shrink_path' fish; then
                lastfull=1
                short=1
                tilde=1
        fi
        if zstyle -t ':prompt:shrink_path' nameddirs; then
                tilde=1
                named=1
        fi
        zstyle -t ':prompt:shrink_path' last && lastfull=1
        zstyle -t ':prompt:shrink_path' short && short=1
        zstyle -t ':prompt:shrink_path' tilde && tilde=1

        while [[ $1 == -* ]]; do
                case $1 in
                        -f|--fish)
                                lastfull=1
                                short=1
                                tilde=1
                        ;;
                        -h|--help)
                                print 'Usage: shrink_path [-f -l -s -t] [directory]'
                                print ' -f, --fish      fish-simulation, like -l -s -t'
                                print ' -l, --last      Print the last directory''s full name'
                                print ' -s, --short     Truncate directory names to the first character'
                                print ' -t, --tilde     Substitute ~ for the home directory'
                                print ' -T, --nameddirs Substitute named directories as well'
                                print 'The long options can also be set via zstyle, like'
                                print '  zstyle :prompt:shrink_path fish yes'
                                return 0
                        ;;
                        -l|--last) lastfull=1 ;;
                        -s|--short) short=1 ;;
                        -t|--tilde) tilde=1 ;;
                        -T|--nameddirs)
                                tilde=1
                                named=1
                        ;;
                esac
                shift
        done

        typeset -a tree expn
        typeset result part dir=${1-$PWD}
        typeset -i i

        [[ -d $dir ]] || return 0

        if (( named )) {
                for part in ${(k)nameddirs}; {
                        [[ $dir == ${nameddirs[$part]}(/*|) ]] && dir=${dir/#${nameddirs[$part]}/\~$part}
                }
        }
        (( tilde )) && dir=${dir/#$HOME/\~}
        tree=(${(s:/:)dir})
        (
                if [[ $tree[1] == \~* ]] {
                        cd -q ${~tree[1]}
                        result=$tree[1]
                        shift tree
                } else {
                        cd -q /
                }
                for dir in $tree; {
                        if (( lastfull && $#tree == 1 )) {
                                result+="/$tree"
                                break
                        }
                        expn=(a b)
                        part=''
                        i=0
                        until [[ (( ${#expn} == 1 )) || $dir = $expn || $i -gt 99 ]]  do
                                (( i++ ))
                                part+=$dir[$i]
                                expn=($(echo ${part}*(-/)))
                                (( short )) && break
                        done
                        result+="/$part"
                        cd -q $dir
                        shift tree
                }
                echo ${result:-/}
        )
}

## vim:ft=zsh
