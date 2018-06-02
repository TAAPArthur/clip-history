#!/usr/bin/env python3
import sys
from pathlib import Path
from gi.repository import Gtk, Gdk

CLIPBOARD_DIRECTORY = str(Path.home())+"/Documents/Clipboard/"
clipboards=(("primary", Gdk.SELECTION_PRIMARY), ("secondary", Gdk.SELECTION_SECONDARY), ("clipboard", Gdk.SELECTION_CLIPBOARD))

def onChange(clipboard, fileName):
    with open(CLIPBOARD_DIRECTORY+fileName, "w") as f:
        f.write(clipboard.wait_for_text())


def getGenerator(board, name):
    return lambda *args: onChange(board, name)


def run():
    validClipboards = set()
    for arg in sys.argv[1:]:
        validClipboards.add(arg)
    for name, id in clipboards:
        if len(validClipboards) == 0 or name in validClipboards:
            print(name)
            board = Gtk.Clipboard.get(id)
            board.connect('owner-change', getGenerator(board, name))
    Gtk.main()


if __name__ == "__main__":
    run()
