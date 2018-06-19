#!/usr/bin/env python3
import sys
import os
from pathlib import Path
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, Gdk

CLIPBOARD_DIRECTORY = str(Path.home())+"/Documents/.clipboard/"
os.makedirs(CLIPBOARD_DIRECTORY,exist_ok=True)
clipboards = (("primary", Gdk.SELECTION_PRIMARY), ("secondary", Gdk.SELECTION_SECONDARY), ("clipboard", Gdk.SELECTION_CLIPBOARD))

DEFAULT_SELECTION=["clipboard"]

lastValue={}

def onChange(clipboard, fileName):
    with open(CLIPBOARD_DIRECTORY+fileName, "w") as f:
        text=clipboard.wait_for_text()

        if text:
            if lastValue.get(clipboard,"") != text:
                lastValue[clipboard]=text
                f.write(text)
                print(text)


def getGenerator(board, name):
    return lambda *args: onChange(board, name)


def run():
    validClipboards = set()
    for arg in sys.argv[1:]:
        if arg in validClipboards:
            validClipboards.add(arg)
    if len(validClipboards) == 0:
        validClipboards = DEFAULT_SELECTION
    for name, id in clipboards:
        if name in validClipboards:
            print(name)
            board = Gtk.Clipboard.get(id)
            board.connect('owner-change', getGenerator(board, name))
    Gtk.main()


if __name__ == "__main__":
    run()
