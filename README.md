# Overview

This repository contains all configs and scripts 
to run a backup of the home directory using DAR.
It will run a full backup per year, 
a differential one per week and 
an incremental one per day.
In im my config it will encrypt the backups and create PAR2 repair files.

# Requirements

* [dar](http://dar.linux.free.fr)
* [par2cmdline](https://github.com/BlackIkeEagle/par2cmdline)

# Installation

Change the configs for your needs - at least correct your username in 
*/home/kai/...* in darrc.

Copy the files to the destination in their headers.
The file containing encryption algorithm and password, 
*.darcrypt.dcf*, of course you have to create by your own 
(*-K* option of dar).

Create a writable directory */opt/backup/$USER* or whatever you will name.

# Usage

It's intended to be run by cron, e. g. using the following:

    # Every three hours check if backups it's necessary to do a backup.
    0 */3 * * * $HOME/bin/backup.sh
    
If run manually, it must be run out of $HOME, 

# License

As far as the file itself does not refer to another license type,
all contets are released under GPL v3 (compare with LICENSE.txt)
