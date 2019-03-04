######################################## Extra ########################################
alias l="exa"
alias ls="exa"
alias ll="exa -l"
alias la="exa -la"

auto-ls () {
  if [[ $#BUFFER -eq 0 ]]; then
    zle && echo ""
    exa -l
    
    zle && zle redisplay
  else
    zle .$WIDGET
  fi
}

zle -N auto-ls
zle -N accept-line auto-ls
chpwd_functions+=(auto-ls)
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

######################################## Prompt ########################################

# lean prompt theme
# by Miek Gieben: https://github.com/miekg/lean
#
# Based on Pure by Sindre Sorhus: https://github.com/sindresorhus/pure
# Colors used: (see Vim's iceberg theme)
# 242 is the gray that is used.
# 110 is the blue.
# 150 is the yellow.
#
# MIT License

COLOR1=${PROMPT_LEAN_COLOR1-"242"}
COLOR2=${PROMPT_LEAN_COLOR2-"110"}
COLOR3=${PROMPT_LEAN_COLOR3-"150"}

PROMPT_LEAN_TMUX=${PROMPT_LEAN_TMUX-"t "}
PROMPT_LEAN_PATH_PERCENT=${PROMPT_LEAN_PATH_PERCENT-20}
PROMPT_LEAN_NOTITLE=${PROMPT_LEAN_NOTITLE-0}
PROMPT_LEAN_ABBR_METHOD=${PROMPT_LEAN_ABBR_METHOD-"shrink"}

prompt_lean_help() {
  cat <<'EOF'
This is a one line prompt that tries to stay out of your face. It utilizes
the right side prompt for most information, like the CWD. The left side of
the prompt is only a '%'. The only other information shown on the left are
the jobs numbers of background jobs. When the exit code of a process isn't
zero the prompt turns red. If a process takes more then 5 (default) seconds
to run the total running time is shown in the next prompt.

Configuration:

PROMPT_LEAN_TMUX: used to indicate being in tmux, set to "t ", by default
PROMPT_LEAN_LEFT: executed to allow custom information in the left side
PROMPT_LEAN_RIGHT: executed to allow custom information in the right side
PROMPT_LEAN_COLOR1: jobs and VCS info indicator color
PROMPT_LEAN_COLOR2: prompt character and directory color
PROMPT_LEAN_COLOR3: elapsed time indicator color
PROMPT_LEAN_VIMODE: used to determine wether or not to display indicator
PROMPT_LEAN_VIMODE_FORMAT: Defaults to "%F{red}[NORMAL]%f"
PROMPT_LEAN_NOTITLE: used to determine wether or not to set title, set to 0
 by default. Set it to your own condition, make it to be 1 when you don't
 want title.
PROMPT_LEAN_ABBR_METHOD: used to indicate the abbreviation method for directory
paths. Set it either to 'truncate' (default) or 'shrink' (fish-style
working directory)

You can invoke it thus:

  prompt lean

EOF
}

# turns seconds into human readable time, 165392 => 1d 21h 56m 32s
prompt_lean_human_time() {
    local tmp=$1
    local days=$(( tmp / 60 / 60 / 24 ))
    local hours=$(( tmp / 60 / 60 % 24 ))
    local minutes=$(( tmp / 60 % 60 ))
    local seconds=$(( tmp % 60 ))
    (( $days > 0 )) && echo -n "${days}d "
    (( $hours > 0 )) && echo -n "${hours}h "
    (( $minutes > 0 )) && echo -n "${minutes}m "
    echo "${seconds}s "
}

# fastest possible way to check if repo is dirty
prompt_lean_git_dirty() {
    # check if we're in a git repo
    command git rev-parse --is-inside-work-tree &>/dev/null || return
    # check if it's dirty
    local umode="-uno" #|| local umode="-unormal"
    command test -n "$(git status --porcelain --ignore-submodules ${umode} 2>/dev/null | head -100)"

    (($? == 0)) && echo ' +'
}

# displays the exec time of the last command if set threshold was exceeded
prompt_lean_cmd_exec_time() {
    local stop=$EPOCHSECONDS
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start
    (($elapsed > ${PROMPT_LEAN_CMD_MAX_EXEC_TIME:=5})) && prompt_lean_human_time $elapsed
}

prompt_lean_set_title() {
    # shows the current tty and dir and executed command in the title when a process is active
    print -Pn "\e]0;"
    print -Pn "%l %1d"
    print -rn ": $1"
    print -Pn "\a"
}

prompt_lean_preexec() {
    cmd_timestamp=$EPOCHSECONDS
    local lean_no_title=$PROMPT_LEAN_NOTITLE
    (($lean_no_title != 1)) && prompt_lean_set_title "$1"
    unset lean_no_title
}

prompt_lean_pwd() {
    local lean_path="`print -Pn '%~'`"
    if (($#lean_path / $COLUMNS.0 * 100 > ${PROMPT_LEAN_PATH_PERCENT:=60})); then
		case "$PROMPT_LEAN_ABBR_METHOD" in
			"truncate") prompt_lean_abbr_truncate;;
			"shrink")   prompt_lean_abbr_shrink;;
		esac
        return
    fi
    print "$lean_path"
}

prompt_lean_abbr_truncate() {
	print -Pn '...%2/'
}

prompt_lean_abbr_shrink() {
	setopt local_options extendedglob histsubstpattern

	local lean_path=$(print -Pn '%~')
	local maxlen=$((PROMPT_LEAN_PATH_PERCENT * COLUMNS / 100))
	local prevlen=0

	# iterate until target length achieved or no more abbreviation possible
	while (($#lean_path > maxlen && $#lean_path != prevlen)); do
		prevlen=$#lean_path
		lean_path=${lean_path:s_(#b)([^/])([^/])##/_$match[1]/_}
	done

	echo $lean_path
}

prompt_lean_precmd() {
    vcs_info
    rehash

    local jobs
    local prompt_lean_jobs
    unset jobs
    for a (${(k)jobstates}) {
        j=$jobstates[$a];i='${${(@s,:,)j}[2]}'
        jobs+=($a${i//[^+-]/})
    }
    # print with [ ] and comma separated
    prompt_lean_jobs=""
    [[ -n $jobs ]] && prompt_lean_jobs="%F{"$COLOR1"}["${(j:,:)jobs}"] "

    local lean_vimode_default="%F{red}[NORMAL]%f"
    #If LEAN_VIMODE is set, set lean_vimode_indicator to either PROMPT_LEAN_VIMOD_FORMAT or a default value
    local lean_vimode_indicator="${PROMPT_LEAN_VIMODE:+${PROMPT_LEAN_VIMODE_FORMAT:-${lean_vimode_default}}}"

    prompt_lean_vimode="${${KEYMAP/vicmd/$lean_vimode_indicator}/(main|viins)/}"

    setopt promptsubst
    local vcs_info_str='$vcs_info_msg_0_' # avoid https://github.com/njhartwell/pw3nage
    PROMPT="$prompt_lean_jobs%F{"$COLOR3"}${prompt_lean_tmux}%f`$PROMPT_LEAN_LEFT`%f%(?.%F{"$COLOR2"}.%B%F{203}%K{234})%#%f%k%b "
    RPROMPT="%F{"$COLOR3"}`prompt_lean_cmd_exec_time`%f$prompt_lean_vimode%F{"$COLOR2"}`prompt_lean_pwd`%F{"$COLOR1"}$vcs_info_str`prompt_lean_git_dirty`$prompt_lean_host%f`$PROMPT_LEAN_RIGHT`%f"

    unset cmd_timestamp # reset value since `preexec` isn't always triggered
}

function zle-keymap-select {
    prompt_lean_precmd
    zle reset-prompt
}

prompt_lean_setup() {
    prompt_opts=(cr percent sp subst)

    zmodload zsh/datetime
    autoload -Uz add-zsh-hook
    autoload -Uz vcs_info

    [[ "$PROMPT_LEAN_VIMODE" != '' ]] && zle -N zle-keymap-select

    add-zsh-hook precmd prompt_lean_precmd
    add-zsh-hook preexec prompt_lean_preexec

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git*' formats ' %b'
    zstyle ':vcs_info:git*' actionformats ' %b|%a'

    [[ "$SSH_CONNECTION" != '' ]] && prompt_lean_host=" %F{"$COLOR3"}%m%f"
    [[ "$TMUX" != '' ]] && prompt_lean_tmux=$PROMPT_LEAN_TMUX

    return 0
}

prompt_lean_setup "$@"
