PREFIX = /usr/local

install:
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@cp -f haxmaps ${DESTDIR}${PREFIX}/bin
	@chmod 755 ${DESTDIR}${PREFIX}/bin/haxmaps

.PHONY: install
