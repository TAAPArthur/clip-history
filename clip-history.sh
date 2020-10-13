#!/bin/bash
#================================================================
# HEADER
#================================================================
#%Usage: ${SCRIPT_NAME} [CLIPBOARD] ACTION
#% Clipboard history recorder
#%
#%CLIPBOARD:
#% --primary
#% --secondary
#% --clipboard (default)
#%
#%Action:
#%Note: All actions take an option argument specifying which clipboard to use (the default is clipboard)
#%    dedup                         Removes duplicates by keeping the latest entry
#%    filter-long [NUM_CHARS]       Removes all entries with more than NUM_CHARS characters
#%    get      i                    get the element at the given index from the specified clipboard. Index 1 is the most recent and -1 the least recent
#%    list     i                    lists the last i element (if i is negative list the first i elements)
#%    monitor                       listen for changes to the specified clipboards. Clipboards should be space separated
#%    select [i] [ARGS]             Using $DMENU, let the user interactively select from the last i (defaults to all) elements. The selected element is printed and added to the corresponding selection
#%    -h, --help                    Print this help
#%    -v, --version                 Print script information
#%
#%Examples:
#%    ${SCRIPT_NAME} monitor             #start monitoring
#%    DMENU=rofi ${SCRIPT_NAME} select >> file"             #select text from clipboard history using rofi instead of dmenu and write it to file
#%    ${SCRIPT_NAME} list 2              #print the 2nd recent clipboard entry
#%    ${SCRIPT_NAME} list -2             #print the 2nd clipboard entry
#%    ${SCRIPT_NAME} select clipboard && xclip --selection clipboard | xvkbd -window $_WIN_ID -file -                #select text from clipboard history and 'type' into the window with id $_WIN_ID
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} (taaparthur.no-ip.org)
#-    author          Arthur Williams
#-    license         MIT
#================================================================
# END_OF_HEADER
#================================================================
#MAN generated with help2man -No clip-history.1 ./clip-history.sh

set -e
set -o pipefail

[ -z "$CLIP_HISTORY_DIR" ] && CLIP_HISTORY_DIR=${XDG_DATA_HOME:-$HOME/.local/share}/clip-history
export DMENU=${DMENU:-dmenu}
mkdir -p $CLIP_HISTORY_DIR
clipboard=


monitor(){
    args=$( ([ -z $* ] && echo $clipboard || echo $*) | tr a-z A-Z)
    clip-monitor $args | while IFS= read -r var; do
        echo $var

        if [ "$var" -eq 1 ] ; then
            selection="primary"
        elif [ "$var" -eq 2 ] ; then
            selection="secondary"
        else
            selection="clipboard"
        fi
        (xclip -r -selection $selection -o | tr "\n" "\r"; echo) >> $CLIP_HISTORY_DIR/$selection
    done
}
dedup(){
    cp $CLIP_HISTORY_DIR/$clipboard /tmp/$clipboard
    entries=$(wc -l $CLIP_HISTORY_DIR/$clipboard | cut -d" " -f1)
    tac $CLIP_HISTORY_DIR/$clipboard | nl -s " " -n rz | sort -k2 -u |sort -r |cut -d" " -f2- > $CLIP_HISTORY_DIR/$clipboard.tmp
    mv $CLIP_HISTORY_DIR/$clipboard.tmp $CLIP_HISTORY_DIR/$clipboard
    newEntries=$(wc -l $CLIP_HISTORY_DIR/$clipboard | cut -d" " -f1)
    echo "removed $((entries - $newEntries)) entries ($entries - $newEntries)"
}
list(){
    limit=$1
    if [[ "$limit" -gt 0 ]];then
        tail -n $limit $CLIP_HISTORY_DIR/$clipboard |tac
    elif [[ "$limit" -lt 0 ]];then
        head -n $((-limit)) $CLIP_HISTORY_DIR/$clipboard | tac
    else
        tac $CLIP_HISTORY_DIR/$clipboard
    fi
}
get(){
    num=${1:1}
    if [[ "$num" -gt 0 ]];then
        tail -n $num $CLIP_HISTORY_DIR/$clipboard |head -n1
    elif [[ "$num" -lt 0 ]];then
        head -n $((-num)) $CLIP_HISTORY_DIR/$clipboard | tail -n1
    fi
}
filterLong(){
    num=${1:-80}
    cp $CLIP_HISTORY_DIR/$clipboard /tmp/$clipboard.bk || true
    sed -Ei "/.{$num,}$/d" $CLIP_HISTORY_DIR/$clipboard
}
displayHelp(){
    SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
    SCRIPT_NAME="$(basename ${0})"
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ;
}
displayVersion(){
    echo "0.8.0"
}
clipboard=${CLIPBOARD:-clipboard}
case $1 in
    --primary|--secondary|--clipboard)
        clipboard=${1:2}
        shift
        ;;
esac

case $1 in
    --help | -h)
        displayHelp
        ;;
    --version | -v)
        displayVersion
        ;;
    monitor)
        shift
        monitor $*
        ;;
    dedup)
        shift
        dedup
        ;;
    get)
        shift
        get $*
        ;;
    filter-long)
        shift
        filterLong $*
        ;;
    list)
        shift
        list $*
        ;;
    select)
        shift
        if [[ $1 =~ '^[-+][0-9]+$' ]]; then
            limit=$1
            shift
        fi
        list $limit | $DMENU $* | tr "\r" "\n" | xclip -r -i -selection $clipboard
        ;;
    *)
        echo "'$*' isn't valid"
        displayHelp
        exit 1
        ;;
esac
