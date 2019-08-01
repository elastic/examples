PREFIX ?= /usr/local

install:
	install -d $(DESTDIR)/etc/watching_the_elastic_watcher/watches
	install -m 0644 watches/* $(DESTDIR)/etc/watching_the_elastic_watcher/watches/
	install -d $(DESTDIR)$(PREFIX)/bin/
	install -m 0755 watching_the_elastic_watcher $(DESTDIR)$(PREFIX)/bin/
	install -d $(DESTDIR)/etc/systemd/system/
	install -m 0644 systemd/* $(DESTDIR)/etc/systemd/system/
	systemctl daemon-reload
	systemctl enable watching_the_elastic_watcher.timer
	systemctl start watching_the_elastic_watcher.timer
