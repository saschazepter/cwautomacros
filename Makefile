# Set the environment variable CWAUTOMACROSPREFIX to install cwautomacros
# in a custom directory. Note that this is just a prefix; all files will
# be installed in $CWAUTOMACROSPREFIX/share/cwautomacros.

ifeq (${CWAUTOMACROSPREFIX},)
# The default installation prefix.
INSTALLPREFIX=/usr
else
# Use installation prefix from environment if set and non-empty.
INSTALLPREFIX=${CWAUTOMACROSPREFIX}
endif

all:
	@echo "Type 'make install' to install in $(INSTALLPREFIX)/share/cwautomacros."

install:
	install -d $(INSTALLPREFIX)/share/cwautomacros
	install -d $(INSTALLPREFIX)/share/cwautomacros/m4
	install --mode 644 m4/*.m4 $(INSTALLPREFIX)/share/cwautomacros/m4
	install -d $(INSTALLPREFIX)/share/cwautomacros/scripts
	for scripts in `ls scripts/*.sh`; do \
	  sed -e 's^@INSTALLPREFIX@^$(INSTALLPREFIX)^g' $$scripts > $(INSTALLPREFIX)/share/cwautomacros/$$scripts; \
	done
	install -d $(INSTALLPREFIX)/share/cwautomacros/templates
	install --mode 755 templates/*.sh $(INSTALLPREFIX)/share/cwautomacros/templates
