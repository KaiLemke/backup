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

# users home directory
BKPFULL1=$BASE-1.1=full-$YEAR	# Full backup
CATFULL1=$BASE-1.1=full_cat-$YEAR	# Catalogue of full backup
BKPFULL2=$BASE-1.2=full-$YEAR	# 2nd half of the year
CATFULL2=$BASE-1.2=full_cat-$YEAR
BKPDIFF=$BASE-2=diff-$YEAR-$WEEK
CATDIFF=$BASE-2=diff_cat-$YEAR-$WEEK
BKPINC=$BASE-3=inc-$DATE
CATINC=$BASE-3=inc_cat-$DATE
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

fullhome1() {
	dar -c $BKPFULL1 -@ $CATFULL1 $BHOME &&
		$MHOME -A $CATFULL1 $BKPFULL1
}		# full backup of home directory and add to database

diffhome1() {
	dar -A $CATFULL1 -c $BKPDIFF -@ $CATDIFF $BHOME &&
		$MHOME -A $CATDIFF $BKPDIFF
}		# differential backup of home directory and add to database

fullhome2() {
	dar -c $BKPFULL2 -@ $CATFULL2 $BHOME &&
		$MHOME -A $CATFULL2 $BKPFULL2
}		# full backup of home directory and add to database

diffhome2() {
	dar -A $CATFULL2 -c $BKPDIFF -@ $CATDIFF $BHOME &&
		$MHOME -A $CATDIFF $BKPDIFF
}		# differential backup of home directory and add to database

inchome() {
	dar -A $CATDIFF -c $BKPINC -@ $CATINC $BHOME &&
		$MHOME -A $CATINC $BKPINC
}		# incremental backup of home directory and add to database

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
	echo "`date +%Y-%m-%d@%T`:   Running backup."
	echo
	if [ $WEEK -ge 27 ];then
		echo "First half of the year."
		echo
		testb "$CATFULL1.1.dar" Full fullhome1
		echo
		testb "$CATDIFF.1.dar" Differential diffhome1
		echo
		testb "$CATINC.1.dar" Incremental inchome
	else
		echo "Second half of the year."
		echo
		testb "$CATFULL2.1.dar" Full fullhome2
		echo
		testb "$CATDIFF.1.dar" Differential diffhome2
		echo
		testb "$CATINC.1.dar" Incremental inchome
	fi;
} > $HOME/log/backup.log
