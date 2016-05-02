#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

#{{{ aliases
# coreutils
alias ls='ls --color=auto'
alias ll='ls --color=auto -l'
alias la='ls --color=auto -a'
alias lla='ls --color=auto -la'
alias lh='ls --color=auto -lh'
alias grep='grep --color=auto'
alias info='info --vi-keys'
alias cdd='cd ..'
alias cddd='cd ../..'
alias psmine='ps -u $(whoami)'

# pacman
alias paci='pacman -Si'
alias pacs='pacman -Ss'
alias pacq='pacman -Qi'
alias FML='sudo pacman -Syu'

# scm
alias gits='git status -s -b -uno'
alias gitsu='git status -s -b -unormal'
alias gitd='git diff'
alias gitdc='git diff --cached'
alias gitl='git log'
alias gitll='git log --stat'
alias gitlp='git log -p'
alias hgs='hg status'
alias hgd='hg diff'
alias hgl='hg log'
alias hgll='hg log -v --stat'
alias hglp='hg log -p'

# Other random stuff
alias mo='mimeo'
alias ff='(firefox &> /dev/null && sleep 1 && pkill "(at-spi|gconfd)" &)'
alias fp='(firefox -private &> /dev/null && sleep 1 && pkill "(at-spi|gconfd)" &)'

#}}}

#{{{ environment variables
[[ -n $SSH_TTY ]] && \
	PS1='\[\e[1m\][\u@\h \W]\$\[\e[0m\] ' || PS1='[\[\e[32m\]\W\[\e[0m\]]\$ '
	# PS1='\[\e[1m\][\u@\h \W]\$\[\e[0m\] ' || PS1='[\[\e[32m\]\@\[\e[0m\] \W]\$ '
eval $(dircolors -b)
export HISTIGNORE="&:ls:ll:la:lla:cd:exit*:acpi:sensors:vmail*:lh:gits:
:gitsu:gitd:gitl:gitll:gitlp:gitb:hgs:hgd:hgl:hgll:hglp:ff:exit:pwd:ghci"
export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
export EDITOR=vim
export SUDO_EDITOR="/usr/bin/vim -p -X"
#}}}

#{{{ color setup
# if [ "$TERM" = "linux" ]; then
# 	eval `dircolors ~/.dircolors_ansi`
# else
# 	eval `dircolors ~/.dircolors_256`
# fi

if [[ -n ${XTERM_SHELL+1} ]] || [[ -f .usecolor ]] && [[ $TERM != "linux" ]]
then
	eval `dircolors ~/.dircolors_256`
fi

# experimental colored man pages:

man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;42;30m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;35m") \
			man "$@"
}
#}}}

#{{{ vim mail

# open vim in mail mode with attachment list from shell glob:
vmail() {
	local tfname=$(mktemp -u --suffix=".mail")
	if (( $# > 0 )); then
		vim -i NONE -n -c "startinsert!" -c "AttachFile $*" -- "$tfname"
		# NOTE: $@ will quote individual arguments, and the above
		# will go horribly wrong.  Must use $*
	else
		vim -i NONE -n -c "startinsert!" -- "$tfname"
	fi
}

# GUI version
vmailg() {
	local tfname=$(mktemp -u --suffix=".mail")
	gvim -i NONE -n -c "startinsert!" -c "let @@='$1'" -- "$tfname"
}

# mail mode with default register storing command output:
# NOTE: usage isn't very natural -- you have to do something like
# vmailc "$(command goes here)" for this to work.
vmailc() {
	local tfname=$(mktemp -u --suffix=".mail")
	vim -i NONE -n -c "startinsert!" -c "let @@='$1'" -- "$tfname"
	# NOTE: we could try to do process substitution here, but
	# this would rule out using aliases, AFAICT
}

#}}}

#{{{ random uncategorized functions

# Toggle synaptics touchpad on/off:
tmouse() {
	local newval=0
	synclient -l | grep -q 'TouchpadOff.*=.*0' && let newval=2
	synclient TouchpadOff=$newval
}

zo() {
	(zathura --fork "$@" &> /dev/null && sleep 1 && pkill at-spi &)
}

zl() {
	local f="$(ls -t /tmp/*.pdf | head -1)"
	echo "Opening $f"
	(zathura --fork "$f" &> /dev/null && sleep 1 && pkill at-spi &)
}

cal() {
	if [[ $1 == "-3" && $# == 1 ]]; then
		command cal $@ | sed -r -e \
		's/(.{22,43})\b('$(date +%-e)')\b(.{22,})/\1\o033[1;31m\2\o033[0m\3/'
	elif (( $# == 0 )); then
		command cal $@ | sed -r -e \
			's/\b('$(date +%-e)')\b/\o033[1;31m\1\o033[0m/g'
	else
		command cal $@
	fi
	# TODO: find clean solution for -y...
}

# draw a dependency graph for a pacman package
pacg() {
	local defaultopts="-d 3"
	if ps -C X &> /dev/null; then
		local tmpsvg=$(mktemp /tmp/XXXXX.svg)
		pactree -g $defaultopts $@ | dot -Tsvg -o $tmpsvg
		viewnior $tmpsvg
		rm $tmpsvg
	else
		pactree -c $defaultopts $@
	fi
}

# see what else is packaged with a binary
complete -c pacelse
pacelse() {
	pacman --color always -Ql $(pacman -Qqo $(which $1)) | less
}

# render + view a dot file.  NOTE: if viewnior worked better, we could just
# do: viewnior <(dot -Tsvg file.dot)
# But it doesn't like reading file descriptors this way.
viewdot () {
	for f in "$@"; do
		local fsvg=$(mktemp /tmp/XXXXX.svg)
		dot -Tsvg -o $fsvg $f
		(viewnior $fsvg && rm $fsvg &)
	done
}

# wrapper for simple C program to generate a password
pgen () {
	local n="12"
	[[ -n "$1" ]] && n="$1"
	command /home/wes/repos/projects/pgen/pgen --len "$n"
}

# scan to pdf
pdfscan () {
	local tfname=$(mktemp -u --suffix=".tiff")
	scanimage --format=tiff > "$tfname"
	local pdfname="scan.pdf"
	if (( $# > 0 )); then
		pdfname="$1"
	fi
	convert "$tfname" -compress jpeg "$pdfname" && \
		rm "$tfname"
}

# find recently touched files, listed by date
recn() {
	# $1 the number to show, $2 is the pattern
	local num=10
	local pat='*'
	(( $# > 0 )) && num="$1"
	(( $# > 1 )) && pat="$2"
	find "./" -type f -name "$pat" -printf '%T@ %p   --- (%TD @%Tl%Tp)\n' \
		| sort -k 1nr | sed 's/^[^ ]* //' | head -$num
}

throwaway_c() {
	local tdir=$(mktemp -d /tmp/deleteme-XXX)
	cd $tdir
	cp ~/.vim/skeletons/skeleton.make Makefile
	cat > test.c <<"EOF"
#include <stdio.h>
#include <stdlib.h>

int main() {
	return 0;
}
EOF
	vim test.c
}

throwaway_cpp() {
	local tdir=$(mktemp -d /tmp/deleteme-XXX)
	cd $tdir
	sed -e 's/LD\s*:=.*$/LD       := $(CXX)/' \
		< ~/.vim/skeletons/skeleton.make > Makefile
	cat > test.cpp <<"EOF"
#include <stdio.h>
#include <stdlib.h>

int main() {
	return 0;
}
EOF
	vim test.cpp
}

remind() {
	if (( $# != 2 )) ; then
		echo "usage: remind <delay> <message>"
		return 1
	fi
	(sleep $1 && notify-send "reminder:" "$2" &)
}

#}}}

#{{{ completion stuff

# ssh config:
ssh_config_hostnames="$(grep -i '^host' ~/.ssh/config | cut -f2 -d ' ')"
complete -o default -W "${ssh_config_hostnames}" ssh
complete -o default -o nospace -W "${ssh_config_hostnames}" scp
unset ssh_config_hostnames
complete -c which
complete -d cd
complete -cf sudo

#{{{  shortcuts / bookmarks
j() {
	cd -P ~/.config/marks/$1 2> /dev/null || echo "Mark [$1] not set."
}

mark() {
	[[ -z $1 ]] && markname=$(basename $PWD) || markname=$1
	ln -sv $PWD ~/.config/marks/$markname
}

unmark() {
	[[ -z $1 ]] && echo "Please enter mark." && return 1
	rm -v ~/.config/marks/$1
}

_marks_show() {
	local cur=${COMP_WORDS[COMP_CWORD]} # stuff typed so far?
	COMPREPLY=($(cd ~/.config/marks/ && ls -d $cur*/ 2> /dev/null)) \
		|| COMPREPLY=()
}

complete -o default -o nospace -F _marks_show j
complete -o default -F _marks_show unmark
#}}}

_pdfps_show() {
	local cur=${COMP_WORDS[COMP_CWORD]} # stuff typed so far
	# NOTE: seems more natural to filter via ls *.{pdf,ps}, but when there
	# aren't any matches for one or the other, you get a bad return code
	# and are dumped into the || section...
	local ifs=$IFS
	IFS=$'\n' COMPREPLY=($(ls -dp $cur* 2> /dev/null | grep -i '\(\.pdf\|\.ps\|/\)$')) \
		|| COMPREPLY=()
	IFS=$ifs
	# NOTE: if the filename has spaces and whatnot, you'll need to quote it.
}

complete -o default -o nospace -F _pdfps_show zo

#}}}

# vim:foldmethod=marker:foldmarker={{{,}}}
