#!/bin/bash
# dupr (install) v0.1
# Made by Dr. Waldijk
# Read the README.md for more info.
# By running this script you agree to the license terms.
# -----------------------------------------------------------------------------------
if [ ! -d $HOME/.dokter ]; then
    mkdir $HOME/.dokter
fi
if [ ! -d $HOME/.dokter/dupr ]; then
    mkdir $HOME/.dokter/dupr
fi
wget -q -N --show-progress https://raw.githubusercontent.com/DokterW/dupr/master/start.sh -P $HOME/.dokter/dupr/
if [ ! -x $HOME/.dokter/dupr/start.sh ]; then
    chmod +x $HOME/.dokter/dupr/start.sh
fi
echo "alias dupr='$HOME/.dokter/dupr/start.sh'" >> $HOME/.bashrc
DUPRINST=$(pwd)
rm -f $FUPRINST/install_dupr.sh
# alias dupr='$HOME/.dokter/dupr/start.sh'
