#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <X11/extensions/Xfixes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argv, const char** args) {
    Display* dpy;
    Window root;
    Atom clip;
    XEvent event;
    int event_base, error_base;
    dpy = XOpenDisplay(NULL);
    if(!dpy) {
        fprintf(stderr, "Can't open X display\n");
        exit(1);
    }
    root = DefaultRootWindow(dpy);
    XFixesQueryExtension(dpy, &event_base, &error_base);
    int n = 1;
    int noLoop = 0;
    if(argv > n)
        if(strcmp("--no-loop", args[n]) == 0) {
            n++;
            noLoop = 0;
        }
    int i;
    for(i = n; i < argv; i++) {
        XFixesSelectSelectionInput(dpy, root, XInternAtom(dpy, args[i], False), XFixesSetSelectionOwnerNotifyMask);
    }
    if(i == n) {
        clip = XInternAtom(dpy, "CLIPBOARD", False);
        XFixesSelectSelectionInput(dpy, root, XA_PRIMARY, XFixesSetSelectionOwnerNotifyMask);
        XFixesSelectSelectionInput(dpy, root, XA_SECONDARY, XFixesSetSelectionOwnerNotifyMask);
        XFixesSelectSelectionInput(dpy, root, clip, XFixesSetSelectionOwnerNotifyMask);
    }
    do {
        XNextEvent(dpy, &event);
        XFixesSelectionNotifyEvent* selectionEvent = (XFixesSelectionNotifyEvent*)&event;
        printf("%ld\n", selectionEvent->selection);
        fflush(NULL);
    } while(!noLoop);
    XCloseDisplay(dpy);
}
