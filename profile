[ -e /tmp/.failsafe ] && export FAILSAFE=1

[ -f /etc/banner ] && cat /etc/banner
[ -n "$FAILSAFE" ] && cat /etc/banner.failsafe

grep -Fsq '/ overlay ro,' /proc/mounts && {
	echo 'Your JFFS2-partition seems full and overlayfs is mounted read-only.'
	echo 'Please try to remove files from /overlay/upper/... and reboot!'
}

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
export HOME=$(grep -e "^${USER:-root}:" /etc/passwd | cut -d ":" -f 6)
export HOME=${HOME:-/root}
export PS1='\u@\h:\w\$ '
export ENV=/etc/shinit



# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
if [ $(id -u) -eq 0 ]; then
  # root user
  export PS1='\[\e[0;34m\]$(date +%y.%m.%d), $(date +%H:%M:%S)\[\e[0m\]\n\[\e[1;32m\][\u@\h]:\[\e[0m\]\[\e[1;35m\]\w\$ \[\e[0m\ '

else
  # non root
  export PS1='\n\e[92m\e[1m\u@\h\e[0m \e[94m\w\n \e[92m\e[1m$\e[0m\e[0m\e[39m\e[49m '

fi

# shortcuts
alias la='ls $LS_OPTIONS -all -h'



case "$TERM" in
	xterm*|rxvt*)
		export PS1='\[\e]0;\u@\h: \w\a\]'$PS1
		;;
esac

[ -n "$FAILSAFE" ] || {
	for FILE in /etc/profile.d/*.sh; do
		[ -e "$FILE" ] && . "$FILE"
	done
	unset FILE
}

if ( grep -qs '^root::' /etc/shadow && \
     [ -z "$FAILSAFE" ] )
then
cat << EOF
=== WARNING! =====================================
There is no root password defined on this device!
Use the "passwd" command to set up a new password
in order to prevent unauthorized SSH logins.
--------------------------------------------------
EOF
fi
