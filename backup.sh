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

# users home directory
BASE=$BACKUPDIR/$HOST-$USER
BKPFULL=$BASE-1=full-$YEAR	# Full backup
CATFULL=$BASE-1=full_cat-$YEAR	# Catalogue of full backup
BKPDIFF=$BASE-2=diff-$YEAR-$WEEK
CATDIFF=$BASE-2=diff_cat-$YEAR-$WEEK
BKPINC=$BASE-2=inc-$DATE
CATINC=$BASE-2=inc_cat-$DATE
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

testdir() {
	if [ ! -d $1 ];then
		mkdir $1
	fi;
}

testman() {
	if [ ! -f $BASE.dmd ];then
		dar_manager -C $BASE.dmd
	fi;
}

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

makefull() {
	bkp=$1	# backup
	cat=$2	# catalogue
	opt=$3	# options
	man=$4	# manager
	dar -c $bkp -@ $cat $opt &&
		$man -A $cat $bkp
}		# full backup and add to database

makediff() {
	highcat=$1
	bkp=$2
	lowcat=$3
	opt=$4
	man=$5
	dar -A $highcat -c $bkp -@ $lowcat $opt &&
		$man -A $lowcat $bkp
}		# differential / incremental backup and add to database

fullhome() {
	makefull $BKPFULL $CATFULL $BHOME $MHOME
}		# full backup of home directory and add to database

diffhome() {
	makediff $CATFULL $BKPDIFF $CATDIFF $BHOME $MHOME
}

inchome() {
	makediff $CATDIFF $BKPINC $CATINC $BHOME $MHOME
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
	testb "$CATFULL.1.dar" Full fullhome
	testb "$CATDIFF.1.dar" Differential diffhome
	testb "$CATINC.1.dar" Incremental inchome
} > $HOME/log/backup.log
