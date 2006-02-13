#!/bin/sh

# Clueless user check.
if test ! -d CVS -a ! -d .svn -a -f configure; then
  echo "You only need to run './autogen.sh' when you checked out this project using CVS."
  echo "Just run ./configure [--help]."
  echo "If you insist on running it, then first remove the 'configure' script."
  exit 0
fi

if test ! -f /usr/share/cwautomacros/autogen.sh; then
  echo "This project needs 'cwautomacros'. See http://cwautomacros.berlios.de/"
fi

exec /usr/share/cwautomacros/autogen.sh
