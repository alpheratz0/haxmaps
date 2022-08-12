.POSIX:
.PHONY: install uninstall default

PREFIX    = /usr/local
MANPREFIX = $(PREFIX)/share/man

default:
	@true

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f haxmaps $(DESTDIR)$(PREFIX)/bin
	chmod 755 $(DESTDIR)$(PREFIX)/bin/haxmaps
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f haxmaps.1 $(DESTDIR)$(MANPREFIX)/man1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/haxmaps.1

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/haxmaps
	rm -f $(DESTDIR)$(MANPREFIX)/man1/haxmaps.1
