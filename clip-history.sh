#!/bin/bash

set -e
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

case $1 in
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
        echo -e $(list $* | $CLIP_HISTORY_SHOW_CMD) |xsel -i --$clipboard
        xsel --clipboard
esac
