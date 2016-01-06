#!/bin/sh

##################################################################################
#                                                                                #
# @path	~/bin/bkp2disk.sh                                                        #
# @author	Kai Lemke <kai.lemke91@gmx.de>                                   #      
# @url		http://github.com/KaiLemke/backup                                #
# @about	copy backups to external hard drive                              #       
#                                                                                #
# Sections:                                                                      #
# 	01. Settings                                                             #
# 	02. Options                                                              #
# 	03. Body                                                                 #
#                                                                                #
##################################################################################

# 01. Settings
# ------------
USER=`whoami`
HOST=`hostname`
LOG=$HOME/log/bkp2disk.log
SOURCES=(/opt/backup/$USER/)
TARGET="/run/media/kai/DaSiK/$USER/backup/$HOST/"

# 02. Options:
# ------------
# -v	verbose
# -h	human readable
# -a	recursevilely, preserve soft links, permissions, time, group, owner, devices and special files
# -c	skip based on checksum, not mod-time & size
# -E	preserve executability
# -P	keep partially transferred files and show progress

# 03. Body
# --------
notify-send -u low "bkp2disk.sh" "Starting."
rsync -v -h --log-file=$LOG -acEP $SOURCES $TARGET
notify-send -u low "bkp2disk.sh" "Done."
