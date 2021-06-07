#Uncomment the following line to debug run of shell
#zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# RIGHT PROMPT
RPROMPT="%T"

alias sudo='sudo '

# SYMFONY PATH
export PATH="$HOME/.symfony/bin:$PATH"

# COMMON ALIASES
alias edit-shell='sudo vim ~/.zshrc'
alias es='edit-shell'
alias save-zsh-conf='source ~/.zshrc'
alias szc='save-zsh-conf'
alias ws='cd ~/workspace'
alias pstorm='sh /opt/PhpStorm-*/bin/phpstorm.sh &'
alias arld='sudo service apache2 reload'
alias unrar-here='unrar e -r'

# SYMFONY ALIASES
alias devlog='tail -f var/log/dev.log'
alias dl='devlog'
alias services='bin/console debug:autowiring'
alias server-start='symfony server:start'

# GIT ALIASES
alias add='git add .'
alias commit='git commit -m'
alias gcb='git commit -m "[$(git_current_branch)]'
alias master='git checkout master'
alias devel='git checkout devel'
alias new-branch='git checkout -b'
alias status='git status'
alias clean='git clean -f -d;'
alias revert='git checkout HEAD'
alias damelotodopapi='git pull origin master'
alias daselotodopapi='git push origin $(git_current_branch)'
alias ahead='git log origin/master..HEAD'

# REVERSE SEARCH BINDKEY
_reverse_search() {
	local selected_command=$(fc -rl 1 | awk '{$1="";print substr($0,2)}' | fzf)
	echo -n $selected_command
}

zle -N _reverse_search
bindkey '^r' _reverse_search
#END REVERSE SEARCH BINDKEY

#IS IN GIT REPO
function is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}
#END IS IN GIT REPO

#INTERACTIVE GIT SHOW MODIFIED FILES
function git_show_not_added_files() {
	is_in_git_repo || return

	selected_file=$(git ls-files -m | fzf)
}
#END INTERACTIVE GIT SHOW MODIFIED FILES

#INTERACTIVE GIT ADD
function git_add {
	git_show_not_added_files || return
		
	$(git add $selected_file)	
	echo "$selected_file added correctly"
}
#END INTERACTIVE GIT ADD

#INTERACTIVE GIT REVERT
function git_revert {
	git_show_not_added_files || return

	git checkout HEAD $selected_file
	echo "$selected_file reverted"
}
#END INTERACTIVE GIT REVERT

#INTERACTIVE PRETTY GIT DIFF
_pretty_diff() {
	git -c color.status=always status --short |
  fzf --height 100% --ansi \
    --preview '(git diff HEAD --color=always -- {-1} | sed 1,4d)' \
    --preview-window right:65% |
  cut -c4- |
  sed 's/.* -> //' |
  tr -d '\n'
}

zle -N _pretty_diff
bindkey '^l' _pretty_diff
#END INTERACTIVE PRETTY GIT DIFF

#PUSH BRANCH TO DEVEL AND MASTER
function git_push {
	is_in_git_repo || return
	
	local pushed_branch=$(git_current_branch);

	git pull origin master
	
	# Go to devel branch
	devel

	git pull origin devel

	git merge $(pushed_branch)

	# Push current branch
	daselotodopapi

	# Go to master branch
	master

	git pull origin master

	git merge $(pushed_branch)

	# Push current branch
	daselotodopapi

}
#END PUSH BRANCH TO DEVEL AND MASTER

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
