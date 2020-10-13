all: clip-history.1 clip-monitor

install: clip-history.1 clip-monitor
	install -D -m 0755 clip-history.sh "$(DESTDIR)/usr/bin/clip-history"
	install -D -m 0755 clip-monitor "$(DESTDIR)/usr/bin/clip-monitor"
	install -D -m 0755 clip-history-autocomplete.sh "$(DESTDIR)/etc/bash_completion.d/clip-history-autocomplete"
	[ -f clip-history.1 ] && install -m 0744 -Dt "$(DESTDIR)/usr/share/man/man1/" clip-history.1

uninstall:
	rm "$(DESTDIR)/usr/bin/clip-history"
	rm "$(DESTDIR)/usr/bin/clip-monitor"
	rm "$(DESTDIR)/etc/bash_completion.d/clip-history-autocomplete"
	rm "$(DESTDIR)/usr/share/man/man1/clip-history.1"

clip-monitor: clip-monitor.o
	${CC} $^ -o $@  -lX11 -lXfixes

clip-history.1: clip-history.sh
	[ -x /usr/bin/help2man ] && help2man -No clip-history.1 ./clip-history.sh

clean:
	rm -f clip-monitor *.o
