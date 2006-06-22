#! /bin/sh

# Helps bootstrapping the application when checked out from CVS.
# Requires GNU autoconf, GNU automake and GNU which.
#
# Copyright (C) 2004 - 2006, by
#
# Carlo Wood, Run on IRC <carlo@alinoe.com>
# RSA-1024 0x624ACAD5 1997-01-26                    Sign & Encrypt
# Fingerprint16 = 32 EC A7 B6 AC DB 65 A6  F6 F6 55 DD 1C DC FF 61
#

# Do sanity checks.
# Directory check.
if test ! -f autogen.sh; then
  echo "Run ./autogen.sh from the directory it exists in."
  exit 1
fi

# Demand we use configure.ac.
if test ! -f configure.ac; then
  if test -f configure.in; then
    echo "You're using 'configure.in' instead of 'configure.ac'. The autotools react different"
    echo "if you use that old, deprecated name. You should rename it (and fix it)."
  else
    echo "Cannot find 'configure.ac'."
  fi
fi

# Determine if this project uses libtool.
if grep '^[[:space:]]*AM_PROG_LIBTOOL' configure.ac >/dev/null; then
  using_libtool="yes"
else
  using_libtool="no"
fi

# Determine if this project uses gettext.
if grep '^[[:space:]]*AM_GNU_GETTEXT_VERSION' configure.ac >/dev/null; then
  using_getext="yes"
else
  using_gettext="no"
fi

# Determine if this project uses doxygen.
if grep '^[[:space:]]*CW_DOXYGEN' configure.ac >/dev/null; then
  using_doxygen="yes"
else
  using_doxygen="no"
fi

if test ! -f ./autogen_versions; then
  echo "Missing file 'autogen_versions'. This file should define required_libtool_version,"
  echo "required_automake_version and libtoolize_arguments."
  exit 1
fi

. ./autogen_versions

if test "$using_libtool" = "yes"; then
  if test x"$required_libtool_version" = x; then
    echo "The file autogen_versions should define 'required_libtool_version'."
    exit 1
  fi
fi
if test x"$required_automake_version" = x; then
  echo "The file autogen_versions should define 'required_automake_version'."
  exit 1
fi

AUTOMAKE=${AUTOMAKE:-automake}
GETEXT=${GETEXT:-gettext}
ACLOCAL=${ACLOCAL:-aclocal}
AUTOHEADER=${AUTOHEADER:-autoheader}
AUTOCONF=${AUTOCONF:-autoconf}
LIBTOOL=${LIBTOOL:-libtool}
LIBTOOLIZE=${LIBTOOLIZE:-`echo $LIBTOOL | sed -e 's/libtool/libtoolize/'`}

# Sanity checks.
($AUTOCONF --version) >/dev/null 2>/dev/null || (echo "Cannot find '$AUTOCONF'. You need GNU autoconf to install from CVS (ftp://ftp.gnu.org/gnu/autoconf/)"; exit 1) || exit 1
($AUTOMAKE --version) >/dev/null 2>/dev/null || (echo "Cannot find '$AUTOMAKE'. You need GNU automake $required_automake_version or higher to install from CVS (ftp://ftp.gnu.org/gnu/automake/)"; exit 1) || exit 1
if test $using_libtool = "yes"; then
  ($LIBTOOL --version) >/dev/null 2>/dev/null || (echo "Cannot find '$LIBTOOL'. You need GNU libtool $required_libtool_version or higher to install from CVS (ftp://ftp.gnu.org/gnu/libtool/)"; exit 1) || exit 1
fi

# Determine the version of automake.
automake_version=`$AUTOMAKE --version | head -n 1 | sed -e 's/[^12]*\([12]\.[0-9][^ ]*\).*/\1/'`

# Require requested version.
expr_automake_version=`echo "$automake_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
expr_required_automake_version=`echo "$required_automake_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
if expr "$expr_required_automake_version" \> "$expr_automake_version" >/dev/null; then
  $AUTOMAKE --version | head -n 1
  echo ""
  echo "Fatal error: automake $required_automake_version or higher is required. Please set \$AUTOMAKE"
  echo "to point to a newer automake, or upgrade."
  echo ""
  exit 1
fi

if test "$using_libtool" = "yes"; then

  # Determine the version of libtool.
  libtool_version=`$LIBTOOL --version | head -n 1 | sed -e 's/[^12]*\([12]\.[0-9][^ ]*\).*/\1/'`
  libtool_develversion=`$LIBTOOL --version | head -n 1 | sed -e 's/.*[12]\.[0-9].*(\([^ ]*\).*/\1/'`

  # Require required_libtool_version.
  expr_libtool_version=`echo "$libtool_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  expr_required_libtool_version=`echo "$required_libtool_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  if expr "$expr_required_libtool_version" \> "$expr_libtool_version" >/dev/null; then
    $LIBTOOL --version
    echo ""
    echo "Fatal error: libtool version $required_libtool_version or higher is required."
    exit 1
  fi

fi # using_libtool

if test "$using_gettest" = "yes"; then

  # Determine version of gettext.
  gettext_version=`$GETEXT --version | head -n 1 | sed -e 's/[^0]*\(0\.[0-9][^ ]*\).*/\1/'`
  confver=`cat configure.ac | grep '^AM_GNU_GETTEXT_VERSION(' | sed -e 's/^AM_GNU_GETTEXT_VERSION(\([^()]*\))/\1/p' | sed -e 's/^\[\(.*\)\]$/\1/' | sed -e 1q`

  # Require version as specified in configure.ac.
  expr_confver=`echo "$confver" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  expr_gettext_version=`echo "$gettext_version" | sed -e 's%\.%.000%g' -e 's%^%000%' -e 's%0*\([0-9][0-9][0-9]\)%\1%g'`
  if expr "$expr_confver" \> "$expr_gettext_version" >/dev/null; then
    $GETTEXT --version | head -n 1
    echo ""
    echo "Fatal error: gettext version "$confver" or higher is required. Please set \$GETEXT"
    echo "to point to a newer gettext, or upgrade."
    echo ""
    exit 1
  fi

  if [ ! -d intl ]; then
    echo "Setting up internationalization files."
    autopoint --force
    cat intl/Makefile.in | sed -e 's/CPPFLAGS/CXXFLAGS/g' > intl/Makefile.in.new && mv intl/Makefile.in.new intl/Makefile.in
    if [ -f Makefile -a -x config.status ]; then
      CONFIG_FILES=intl/Makefile CONFIG_HEADERS= /bin/sh ./config.status
    fi
  fi

fi # using_gettext

if test "$using_doxygen" = "yes"; then

if test -d "doc"; then
  doc_path="doc"
elif test -d "docs"; then
  doc_path="docs"
elif test -d "documents"; then
  doc_path="documents"
fi

if [ ! -f doc/doxygen.config.in ]; then
  (doxygen --version) >/dev/null 2>/dev/null || (echo -e "\nYou need the package 'doxygen' to generate documentation. Please install it (see http://www.doxygen.org/)."; exit 1) || exit 1
  echo "*WARNING:********************************************"
  echo "* Generating an initial doc/doxygen.config.in file. *"
  echo "* Edit it and add it to your CVS repository!        *"
  doxygen -g doc/doxygen.config.tmp >/dev/null
  echo -e "# @""configure_input""@\n" > doc/doxygen.config.in;
  sed -e 's%^\(PROJECT_NAME[[:space:]=].*\)%\1@PACKAGE_NAME@%' \
      -e 's%^\(PROJECT_NUMBER[[:space:]=].*\)%\1@PACKAGE_VERSION@%' \
      -e 's%^\(OUTPUT_DIRECTORY[[:space:]=].*\)%\1.%' \
      -e 's%^\(INPUT[[:space:]=].*\)%\1@top_srcdir@/src @top_srcdir@/src/include%' \
      -e 's%^\(FILE_PATTERNS[[:space:]=].*\)%\1*.cc *.h%' \
      -e 's%^\(QUIET[[:space:]]*=\).*%\1 YES%' \
      -e 's%^\(PREDEFINED[[:space:]]*=\).*%\1 DOXYGEN protected_notdocumented=private%' \
      -e 's%^\(MACRO_EXPANSION[[:space:]]*=\).*%\1 YES%' \
      -e 's%^\(EXPAND_ONLY_PREDEF[[:space:]]*=\).*%\1 YES%' \
      -e 's%^\(HAVE_DOT[[:space:]]*=\).*%\1 @HAVE_DOT@%' \
      doc/doxygen.config.tmp >> doc/doxygen.config.in
  rm doc/doxygen.config.tmp
  echo "**********************************************(done)*"
fi
#      -e 's%^\(CGI_NAME[[:space:]=].*\)%# Obsoleted: \1%' 

fi # using_doxygen

if test "$using_libtool" = "yes"; then

  # Check if bootstrap was run before and if the installed files are the same version.
  if test -f ltmain.sh; then
    installed_libtool=`grep '^VERSION=' ltmain.sh | sed -e 's/.*\([12]\.[^ ]*\).*/\1/'`
    installed_timestamp=`grep '^TIMESTAMP=' ltmain.sh | sed -e 's/.*(\([0-9]*\.[^ ]*\).*/\1/'`
    if test "$installed_libtool" != "$libtool_version" -o X"$installed_timestamp" != X"$libtool_develversion"; then
      echo "Re-installing new libtool files ($installed_libtool ($installed_timestamp) -> $libtool_version ($libtool_develversion))"
      rm -f config.guess config.sub ltmain.sh ltconfig
    fi
  fi

fi # using_libtool

run()
{
  echo "Running $1 ..."
  $1
}

# This is needed when someone just upgraded automake and this cache is still generated by an old version.
rm -rf autom4te.cache config.cache

if ! grep '^[[:space:]]*ACLOCAL_AMFLAGS[[:space:]]*=' Makefile.am >/dev/null; then
  echo "ACLOCAL_AMFLAGS not set in Makefile.am -- make sure you set it in all Makefile.am's."
  exit 1
fi

ACLOCAL_AMFLAGS=`grep '^[[:space:]]*ACLOCAL_AMFLAGS[[:space:]]*=' Makefile.am | sed -e 's/^[[:space:]]*ACLOCAL_AMFLAGS[[:space:]]*=[[:space:]]*//' -e 's%@ACLOCAL_CWFLAGS@%-I @INSTALLPREFIX@/share/cwautomacros/m4%g'`

if ! echo "$ACLOCAL_AMFLAGS" | grep -- '-I @INSTALLPREFIX@/share/cwautomacros/m4' >/dev/null; then
  echo "*** WARNING: ACLOCAL_AMFLAGS, in Makefile.am, should contain \"-I @INSTALLPREFIX@/share/cwautomacros/m4\""
  echo "***          You can achieve this by adding ACLOCAL_AMFLAGS=@ACLOCAL_CWFLAGS@ to Makefile.am."
fi

run "$ACLOCAL $ACLOCAL_AMFLAGS"
run "$AUTOHEADER"
run "$AUTOCONF"
if test "$using_libtool" = "yes"; then
run "$LIBTOOLIZE --automake $libtoolize_arguments"
fi
if test ! -e depcomp; then
  ln -s @INSTALLPREFIX@/share/cwautomacros/scripts/depcomp.sh depcomp
fi
run "$AUTOMAKE --add-missing --foreign"

echo
project_name=`basename "$PWD"`
if test -n "$CONFIGURE_OPTIONS"; then
  echo 'Now you can do '"'"'mkdir ../'$project_name'-objdir; cd ../'$project_name'-objdir; configure'"'"'.'
else
  echo 'Now you can do '"'"'mkdir ../'$project_name'-objdir; cd ../'$project_name'-objdir; ../'$project_name'/configure --enable-maintainer-mode [--help]'"'"'.'
fi

