alias ls='ls --color -FG' 
#export PS1='\u@\h:\[\e[33m\]\w\[\e[0m\]\$ ' 
export EDITOR='neovim' 
alias ranger='ranger --choosedir=$HOME/.rangerdir; LASTDIR=`cat $HOME/.rangerdir`; cd "$LASTDIR"'
alias vim="nvim" 
alias vi="nvim" 
alias oldvim="vim" 

function ranger { 
    local IFS=$'\t\n' 
    local tempfile="$(mktemp -t tmp.XXXXXX)" 
    local ranger_cmd=( 
        command 
        ranger 
        --cmd="map Q chain shell echo %d > "$tempfile"; quitall" 
    ) 
    ${ranger_cmd[@]} "$@" 
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then 
        cd -- "$(cat "$tempfile")" || return 
    fi 
    command rm -f -- "$tempfile" 2>/dev/null 
} 

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
