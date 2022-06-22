PREFIX = /usr/local

install:
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f src/haxmaps ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/haxmaps

uninstall:
	@rm -f ${DESTDIR}${PREFIX}/bin/haxmaps

.PHONY: install uninstall
