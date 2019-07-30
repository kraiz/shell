#!/bin/bash

# we need git and curl
if ! [ -x "$(command -v git)" ] || ! [ -x "$(command -v curl)" ]; then
  echo 'Install both: git and curl.' >&2
  exit 1
fi

# zsh with zplugin
cat <<-"EOF" > ~/.zshrc
#! zsh

# basics
export EDITOR='vim'
export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'
export PATH="~/.local/bin:~/.npm-packages/bin:$PATH"
export LS_COLORS=$LS_COLORS:'di=0;36:'
export LSCOLORS=gxfxcxdxbxegedabagacad

# tools
alias v='vim'
alias d='docker'
alias dc='docker-compose'
alias tm='tmux -2 attach || tmux -2 new'
alias l='tree --dirsfirst -ChFupDaLg 1 $argv'

# network and processes
alias psg='ps aux | grep -v grep | grep -i'
alias nsl='netstat -taupn | grep LISTEN'
alias nsg='netstat -taupn | grep -i'

# git
alias g='git'
alias ga='git add'
alias gs='git status --short'
alias gst='git status'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gl='git pull'
alias glr='git pull --rebase'
alias gp='git push'

# update shell
alias update-shell="curl -sL https://raw.githubusercontent.com/kraiz/shell/master/install.sh | zsh"

# plugin stuff
export XDG_CACHE_HOME=${XDG_CACHE_HOME:=~/.cache}

typeset -A ZPLGM
ZPLG_HOME=$XDG_CACHE_HOME/zsh/zplugin
ZPLGM[HOME_DIR]=$ZPLG_HOME
ZPLGM[ZCOMPDUMP_PATH]=$XDG_CACHE_HOME/zsh/zcompdump

if [[ ! -f $ZPLG_HOME/bin/zplugin.zsh ]]; then
  git clone https://github.com/psprint/zplugin $ZPLG_HOME/bin
  zcompile $ZPLG_HOME/bin/zplugin.zsh
fi
source $ZPLG_HOME/bin/zplugin.zsh
load=light

zplugin $load willghatch/zsh-saneopt

zplugin $load mafredri/zsh-async
zplugin $load rupa/z
zplugin $load sindresorhus/pure

zplugin ice nocompile:! pick:c.zsh atpull:%atclone atclone:'dircolors -b LS_COLORS > c.zsh'
zplugin $load trapd00r/LS_COLORS

zplugin ice silent wait:1 atload:_zsh_autosuggest_start
zplugin $load zsh-users/zsh-autosuggestions

zplugin ice blockf; zplugin $load zsh-users/zsh-completions

zplugin ice silent wait:1; zplugin $load mollifier/cd-gitroot
zplugin ice silent wait:1; zplugin $load micha/resty
zplugin ice silent wait:1; zplugin $load supercrabtree/k

zplugin ice silent wait!1 atload"ZPLGM[COMPINIT_OPTS]=-C; zpcompinit"
zplugin $load zdharma/fast-syntax-highlighting

# Install `fzy` fuzzy finder, if not yet present in the system
# Also install helper scripts for tmux and dwtm
zplugin ice silent wait:1 as"command" if'[[ -z "$commands[fzy]" ]]' \
       make"!PREFIX=$ZPFX install" atclone"cp contrib/fzy-* $ZPFX/bin/" pick"$ZPFX/bin/fzy*"
    $load jhawthorn/fzy
# Install fzy-using widgets
zplugin ice silent wait:1; zplugin $load aperezdc/zsh-fzy
bindkey '\ec' fzy-cd-widget
bindkey '^T'  fzy-file-widget
bindkey '^R'  fzy-history-widget
bindkey '^P'  fzy-proc-widget

zstyle :fzy:tmux    enabled      no
zstyle :prompt:pure:path color cyan
EOF

# tmux
cat <<-"EOF" > ~/.tmux.conf
# basic settings
set -g history-limit 50000
set -g default-terminal "screen-256color"
set -g base-index 1
setw -g pane-base-index 1
setw -g automatic-rename off
set-environment -g CHERE_INVOKING 1

# use C-a instead of C-b
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# intuitive pane creation
bind | split-window -h
bind - split-window -v

# broadcast toggle
bind b setw synchronize-panes

# Smart pane switching vim-style
bind -n C-h select-pane -L
bind -n C-j select-pane -D
bind -n C-k select-pane -U
bind -n C-l select-pane -R

# Window navigation
bind -n C-w previous-window
bind -n C-e next-window

# mouse with 3-line-scoll
set -g mouse on
bind -n WheelUpPane if-shell -F -t = "#{mouse_any_flag}" "send-keys -M" "if -Ft= '#{pane_in_mode}' 'send-keys -M; send-keys -M; send-keys -M' 'select-pane -t=; copy-mode -e; send-keys -M; send-keys -M; send-keys -M'"
bind -n WheelDownPane select-pane -t= \; send-keys -M \; send-keys -M \; send-keys -M

# style
set -g message-style fg=colour145,bg=colour236
set -g message-command-style fg=colour145,bg=colour236
set -g pane-active-border-style fg=colour25,bg=colour25
set -g pane-border-style fg=colour233,bg=colour234
set -g window-style fg=colour247,bg=colour234
set -g window-active-style fg=colour250,bg=colour233
set -g status "on"
set -g status-style bg=colour233,none
set -g status-justify "centre"
set -g status-left "#[fg=colour195,bg=colour25,bold] #(whoami)@#H #[fg=colour25,bg=colour236,nobold,nounderscore,noitalics]#[fg=colour145,bg=colour236] #S #[fg=colour236,bg=colour233,nobold,nounderscore,noitalics]"
set -g status-left-style none
set -g status-left-length "100"
set -g status-right "#[fg=colour236,bg=colour233,nobold,nounderscore,noitalics]#[fg=colour145,bg=colour236] %F #[fg=colour25,bg=colour236,nobold,nounderscore,noitalics]#[fg=colour195,bg=colour25] %R "
set -g status-right-style none
set -g status-right-length "100"
setw -g window-status-activity-style fg=colour25,bg=colour233,none
setw -g window-status-style fg=colour240,bg=colour233,none
setw -g window-status-current-format "#[fg=colour233,bg=colour236,nobold,nounderscore,noitalics]#[fg=colour145,bg=colour236] #I #W #[fg=colour236,bg=colour233,nobold,nounderscore,noitalics]"
setw -g window-status-format "#[fg=colour233,bg=colour233,nobold,nounderscore,noitalics]#[default] #I #W #[fg=colour233,bg=colour233,nobold,nounderscore,noitalics]"
setw -g window-status-separator ""
EOF

# vim
touch ~/.vimrc
cat <<-"EOF" > ~/.vimrc
set nocompatible
syntax on

if exists('+colorcolumn')
  highlight ColorColumn ctermbg=235 guibg=#2c2d27
  let &colorcolumn="80,120"
endif

let mapleader=","
let maplocalleader="\\"

set nowrap
set tabstop=2
set softtabstop=2
set expandtab
set copyindent
set number
set shiftwidth=2
set shiftround
set showmatch
set smartcase
set ignorecase
set hlsearch
set pastetoggle=<F2>
set splitbelow
set splitright

set mouse+=a
if &term =~ '^screen'
  set ttymouse=xterm2
endif

set hidden
set nobackup
set noswapfile
set wildmode=list:full
set wildignore=*.swp,*.bak,*.pyc,*.class
set visualbell
set nomodeline
set cursorline
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

nnoremap <leader>s :w<CR>
inoremap <leader>s <Esc>:w<CR>
nnoremap ; :
nnoremap <leader>ve :vsplit $MYVIMRC<cr>
nnoremap <leader>vs :source $MYVIMRC<cr>
nmap <silent> ,/ :nohlsearch<CR>
cmap w!! w !sudo tee % >/dev/null
vnoremap <C-r> "hy:%s/<C-r>h//gc<left><left><left>
nnorema <leader>lu :set ff=unix<CR>
EOF

# npm
if [ -x "$(command -v npm)" ]; then
  npm config set prefix ~/.npm-packages
fi

# git
git config --global core.eol lf
git config --global core.editor "code"
git config --global push.default "tracking"
git config --global color.ui auto
git config --global diff.tool "vscode"
git config --global difftool.vscode.cmd "code --wait --diff $LOCAL $REMOTE"
git config --global core.excludesfile ~/.gitignore

touch ~/.gitignore
declare -a ignores=('.DS_Store')
for i in "${ignores[@]}"; do
  grep -q "$i" ~/.gitignore || echo $i >> ~/.gitignore
done
