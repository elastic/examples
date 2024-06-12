PREFIX ?= /usr/local

install:
	install -d $(DESTDIR)/etc/check_es_watches/watches
	install -m 0644 watches/* $(DESTDIR)/etc/check_es_watches/watches/
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 0755 check_es_watches $(DESTDIR)$(PREFIX)/bin/
	install -d $(DESTDIR)/etc/systemd/system/
	install -m 0644 systemd/* $(DESTDIR)/etc/systemd/system/
	systemctl daemon-reload
	systemctl enable check_es_watches.timer
	systemctl start check_es_watches.timer
