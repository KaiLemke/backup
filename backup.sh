#!/bin/sh

##################################################################################
#                                                                                #
# @path	~/bin/backup_home.sh                                                     #
# @author	Kai Lemke <kai.lemke91@gmx.de>                                   #      
# @url		http://github.com/KaiLemke/backup                                #
# @about	autostart with X server                                          #       
#                                                                                #
# Sections:                                                                      #
# 	01. settings                                                             #
# 	02. functions                                                            #
# 	03. body                                                                 #
#                                                                                #
##################################################################################

# 01. settings
# ------------
DARRC=$HOME/.darrc
HOST=`hostname`
USER=`whoami`
YEAR=`date +%G`
WEEK=`date +%V`
DAY=`date +%u`
DATE=$YEAR-$WEEK-$DAY		# Date: Year - calendar week - day (ISO = Monday first)
BACKUPDIR=/opt/backup/$USER
BASE=$BACKUPDIR/$HOST-$USER
BHOME="
         -R $HOME 
         -zbzip2 
	 -aa 
	 excludes 
	 crypt 
	 par2 
	 compress-exclusion 
	 no-emacs-backup 
	 verbose
	 " 		# options for backup of home directory
MHOME="dar_manager -B $BASE.dmd"		# use dar_manager database for host and user

# 02. functions
# -------------
warn() {
	msg="Starting backup for $*"
	wall -t 600 $msg &
	notify-send -u critical "$msg" &
}		# Make shure, the system will not be shut down.

testman() {
	if [ ! -f $BASE.dmd ];then
		dar_manager -C $BASE.dmd
	fi;
}

testdir() {
	if [ ! -d $1 ];then
		mkdir $1
	fi;
}

bfull() {
	dar -c $BASE-1=full-$YEAR -@ $BASE-1=full_cat-$YEAR $BHOME &&
		$MHOME -A $BASE-1=full_cat-$YEAR $BASE-1=full-$YEAR
}		# full backup of home directory and add to database

bdiff() {
	dar -A $BASE-1=full_cat-$YEAR -c $BASE-2=diff-$YEAR-$WEEK -@ $BASE-2=diff_cat-$YEAR-$WEEK $BHOME &&
		$MHOME -A $BASE-2=diff_cat-$YEAR-$WEEK $BASE-2=diff-$YEAR-$WEEK
}		# differential backup of home directory and add to database

binc() {
	dar -A $BASE-2=diff_cat-$YEAR-$WEEK -c $BASE-3=inc-$DATE -@ $BASE-3=inc_cat-$DATE $BHOME &&
		$MHOME -A $BASE-3=inc_cat-$DATE $BASE-3=inc-$DATE
}		# incremental backup of home directory and add to database

testb() {
	if [ ! -f $1 ];then
		echo "$2 backup for this year will be created."
		echo
		$3
		echo
		echo "$2 backup done."
	else
		echo "$2 backup is already done."
	fi;
}

# 03. body
# --------
# first warn that backup will be build, so no-one will shutsdown during this process
warn $HOME

# test, if there is a log dir
testdir $HOME/log

# test, if there is a dar_manager database
testman

# save an actual list of intalled packages
pacman -Qs > $HOME/log/paclist

# Make backups (full yearly, differential weekly, incremental daily)
# and save a log file
{
	date +%Y-%m-%d@%T
	echo "Running backup."
	testb "$BASE-1=full_cat-$YEAR.1.dar" Full bfull
	testb "$BASE-2=diff_cat-$YEAR-$WEEK.1.dar" Differential bdiff
	testb "$BASE-3=inc_cat-$DATE.1.dar" Incremental binc
} > $HOME/log/backup.log
