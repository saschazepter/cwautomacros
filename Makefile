INSTALLPREFIX=/usr

all:
	@echo "Type 'make install' to install"

install:
	install -d $(INSTALLPREFIX)/share/cwautomacros
	install --mode 644 m4/*.m4 $(INSTALLPREFIX)/share/cwautomacros
	install --mode 755 scripts/*.sh $(INSTALLPREFIX)/share/cwautomacros
