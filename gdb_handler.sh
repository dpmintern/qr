#!/usr/bin/env bash

GDB=$DEVKITARM/bin/arm-none-eabi-gdb

GDBPORT=4000

#BLACK=$(tput setaf 0)
#RED=$(tput setaf 1)
#GREEN=$(tput setaf 2)
#LIME_YELLOW=$(tput setaf 190)
#YELLOW=$(tput setaf 3)
#POWDER_BLUE=$(tput setaf 153)
#BLUE=$(tput setaf 4)
#MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
#WHITE=$(tput setaf 7)
#BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
#BLINK=$(tput blink)
#REVERSE=$(tput smso)
#UNDERLINE=$(tput smul)

function QRBinContentsInGDB() {
    bin=$1
    limit = $2
    #I probably could've used perl but I happen to be incompetent :)
    xxd -p $bin | fold -w2 | while IFS= read -r line; do
        echo "0x$line";
    done | tr "\n" "," | sed 's/...../& /g; s/..$//'
    #| sed "s/.....{$limit\}//"
}
export -f QRBinContentsInGDB

function chooseServer() {
    #if ! kdialog --radiolist \
    #     "What console should we connect to?" $@ >/tmp/RosalinaClient; then
    if ! kdialog --radiolist \
         "What console should we connect to?" $@ | read CHOSEN_IP; then
        echo "Operation cancelled"
        exit
    fi
}
export -f chooseServer

function message() {
    echo "${CYAN}$1${NORMAL}"
}

function scanForGDB() {
    #sometimes this won't pick up anything.
    nmap -Pn -p$GDBPORT --open 192.168.1.1/24 -oG - | \
        grep Up | cut -d ' ' -f 2
}

while [ -z "${IP_ADDRESSES}" ]; do
    message "GDB Server(s) not found. Scanning Again."
    IP_ADDRESSES=$(scanForGDB)
done

message "Rosalina GDB Server(s) found. Building list."
for IP in $IP_ADDRESSES; do
    echo "$IP GDB@$IP on"
done | xargs -I % bash -c 'chooseServer "%"'

# can't use --command since the gdb file is parametric
# we need to run it through bash first

# can't use python automation because devkitARM gdb is compiled without python
# support by default :upside_down_smile:

$GDB < (echo $(<prod.gdb)) #--command=prod.gdb --symbols=symfile
