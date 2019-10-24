install: clip-history.1
	install -D -m 0755 clip-history.sh "$(DESTDIR)/usr/bin/clip-history"
	install -D -m 0755 clip-history-autocomplete.sh "$(DESTDIR)/etc/bash_completion.d/clip-history-autocomplete"
	[ -f clip-history.1 ] && install -m 0744 -Dt "$(DESTDIR)/usr/share/man/man1/" clip-history.1

clip-history.1: clip-history.sh
	[ -x /usr/bin/help2man ] && help2man -No clip-history.1 ./clip-history.sh
