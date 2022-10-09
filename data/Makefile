
include ../config.mk

all:

strip:

install:
	mkdir -p $(DESTDIR)$(datadir)/applications
	$(INSTALL_DATA) app.desktop $(DESTDIR)$(datadir)/applications
	mkdir -p $(DESTDIR)$(datadir)/pixmaps
	$(INSTALL_DATA) app.png $(DESTDIR)$(datadir)/pixmaps
	mkdir -p $(DESTDIR)$(mandir)/man1
	$(INSTALL_DATA) app.1 $(DESTDIR)$(mandir)/man1
	mkdir -p $(DESTDIR)$(sysconfdir)
	$(INSTALL_DATA) app.rc $(DESTDIR)$(sysconfdir)

install-strip: install

uninstall:
	rm -f $(DESTDIR)$(datadir)/applications/app.desktop
	rm -f $(DESTDIR)$(datadir)/pixmaps/app.png
	rm -f $(DESTDIR)$(mandir)/man1/app.1
	rm -f $(DESTDIR)$(sysconfdir)/app.rc

clean:

distclean:


