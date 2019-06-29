#!/bin/bash
#================================================================
# HEADER
#================================================================
#%Usage: ${SCRIPT_NAME} ACTION [clipboard, primary or secondary]
#% Clipboard history recorder
#%
#%
#%Action:
#%Note: All actions take an option argument specifying which clipboard to use (the default is clipboard)
#%    get     [clipboard] i       get the element at the given index from the specified clipboard. Index 1 is the most recent and -1 the least recent
#%    list    [clipboard] i       lists the last i element (if i is negative list the first i elements)
#%    merge   [clipboard]         combine all files matching *clipboard* in $CLIP_HISTORY_DIR into clipboard
#%    monitor [clipboard]         listen for changes to the specified clipboards. Clipboards should be space separated
#%    select  [clipboard]         Using $CLIP_HISTORY_SHOW_CMD, let the user interactively select a history element. This element is printed and added to the corresponding selection
#%    -h, --help                    Print this help
#%    -v, --version                 Print script information
#%
#%Examples:
#%    ${SCRIPT_NAME} monitor             #start monitoring
#%    CLIP_HISTORY_SHOW_CMD=rofi ${SCRIPT_NAME} select >> file"             #select text from clipboard history using rofi instead of dmenu and write it to file
#%    ${SCRIPT_NAME} list 2              #print the 2nd recent clipboard entry
#%    ${SCRIPT_NAME} list -2             #print the 2nd clipboard entry
#%    ${SCRIPT_NAME} select clipboard && xsel --clipboard | xvkbd -window $_WIN_ID -file -                #select text from clipboard history and 'type' into the window with id $_WIN_ID
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
export CLIP_HISTORY_DIR=${CLIP_HISTORY:-$HOME/.local/share/clip-history}
export CLIP_HISTORY_SHOW_CMD=${CLIP_HISTORY_SHOW_CMD:-dmenu}
mkdir -p $CLIP_HISTORY_DIR
clipboard=

monitor(){
    cat << EOF | python $*
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk
import sys
import time

clipboards = (("primary", Gdk.SELECTION_PRIMARY), ("secondary", Gdk.SELECTION_SECONDARY), ("clipboard", Gdk.SELECTION_CLIPBOARD))
DEFAULT_SELECTION = ["clipboard"]
lastValue = {}


def onChange(clipboard, fileName):
    with open('$CLIP_HISTORY_DIR/' + fileName, "a") as f:
        text = clipboard.wait_for_text()
        if text:
            if lastValue.get(clipboard, "") != text:
                lastValue[clipboard] = text
                output="{} {}\n".format(int(time.time()), text.encode("unicode_escape").decode("utf-8"))
                f.write(output)
                f.flush()
                print(output,end="")

validClipboards = set()
for arg in sys.argv[1:]:
    if arg in validClipboards:
        validClipboards.add(arg)
if len(validClipboards) == 0:
    validClipboards = DEFAULT_SELECTION
for name, id in clipboards:
    if name in validClipboards:
        board = Gtk.Clipboard.get(id)
        board.connect('owner-change', lambda *args: onChange(board, name))
Gtk.main()
EOF
}
merge(){
    clipboard=${1:-clipboard}
    sort $CLIP_HISTORY_DIR/*$clipboard* |uniq >/tmp/clipboard
    rm $CLIP_HISTORY_DIR/*$clipboard*
    mv /tmp/$clipboard $CLIP_HISTORY_DIR/$clipboard
}
list(){
    clipboard=${1:-clipboard}
    limit=$3
    if [[ "$limit" -gt 0 ]];then
        tail -n $limit $CLIP_HISTORY_DIR/$clipboard |tac |cut -d" " -f2-
    elif [[ "$limit" -lt 0 ]];then
        head -n $((-limit)) $CLIP_HISTORY_DIR/$clipboard | tac|cut -d" " -f2-
    else
        tac $CLIP_HISTORY_DIR/$clipboard |cut -d" " -f2-
    fi
}
get(){
    clipboard=${1:-clipboard}
    num=${3:1}
    if [[ "$num" -gt 0 ]];then
        tail -n $num $CLIP_HISTORY_DIR/$clipboard |head -n1 |cut -d" " -f2-
    elif [[ "$num" -lt 0 ]];then
        head -n $((-num)) $CLIP_HISTORY_DIR/$clipboard | tail -n1 |cut -d" " -f2-
    fi
}
displayHelp(){
    SCRIPT_HEADSIZE=$(head -200 ${0} |grep -n "^# END_OF_HEADER" | cut -f1 -d:)
    SCRIPT_NAME="$(basename ${0})"
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "^#[%+]" | sed -e "s/^#[%+-]//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g" ;
}
displayVersion(){
    echo "0.4.0"
}

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
    merge)
        shift
        merge $*
        ;;
    get)
        shift
        get $*
        ;;
    list)
        shift
        list $*
        ;;
    select)
        shift
        clipboard=${1:-clipboard}
        echo -en $(list $* | $CLIP_HISTORY_SHOW_CMD) |xsel -i --$clipboard
        xsel --clipboard
esac
