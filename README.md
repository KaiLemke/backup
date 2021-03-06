# Overview

This repository contains all configs and scripts 
to run a backup of the home directory using DAR.
It will run two full backups per year, 
a differential one per week and 
an incremental one per day.
In im my config it will encrypt the backups and create PAR2 repair files.

Directories containing large files or sensitve data are backed up separately, 
because this one is thought to be stored online.

# Requirements

* [dar](http://dar.linux.free.fr)
* [par2cmdline](https://github.com/BlackIkeEagle/par2cmdline)
* [rsync](http://rsync.samba.org/)

# Installation

Change the configs for your needs - at least correct your username in 
*/home/kai/...* in darrc.

Copy the files to the destination in their headers.
The file containing encryption algorithm and password, 
*.darcrypt.dcf*, of course you have to create by your own 
(*-K* option of dar).

Create a writable directory */opt/backup/$USER* or whatever you will name.

# Usage

## backup.sh

It's intended to be run by cron, e. g. using the following:

    # Every three hours check if backups it's necessary to do a backup.
    0 */3 * * * /home/kai/bin/backup.sh
    
If run manually, it must be run out of $HOME, 

## bkp2disk.sh

It's intended to be run manually, after mounting the target device.

# License

As far as the file itself does not refer to another license type,
all contets are released under GPL v3 (compare with LICENSE.txt)
