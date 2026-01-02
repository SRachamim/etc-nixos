co () {
	tmuxinator s fg $1
}

co-b () {
	git worktree -b $1 ../$1
	co $1
}

co-add () {
	git worktree add ../$1 $1
	co $1
}

co-d () {
	git worktree remove $1
}

# Source secrets file if it exists
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

export FZF_DEFAULT_COMMAND='fd -H --type f --strip-cwd-prefix'
PATH=$HOME/.local/bin:$PATH:$HOME/.npm-global/bin
