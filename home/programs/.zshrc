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

