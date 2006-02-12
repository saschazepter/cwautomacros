# CW_OPG_FLAGS m4 macro -- this file is part of cwautomacros.
# Copyright (C) 2006 Carlo Wood <carlo@alinoe.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
# 02111-1307, USA.
#
# As a special exception, the author gives unlimited permission to copy,
# distribute and modify the configure scripts that are the output of
# by a tool like autoconf when using these macros as input.  You need
# not follow the terms of the GNU General Public License when using or
# distributing such scripts, even though portions of the text of this
# file appears in them. The GNU General Public License (GPL) does govern
# all other use of the material that constitutes the cwautomacros project.

dnl CW_OPG_FLAGS
dnl Add --enable-debug (DEBUG, DOXYGEN_DEBUG), --enable-libcwd (CWDEBUG, DOXYGEN_CWDEBUG),
dnl --enable-optimise and --enable-profile options. Update USE_LIBCWD, LIBS and CXXFLAGS accordingly.
AC_DEFUN([CW_OPG_FLAGS], [dnl
m4_pattern_allow(CW_DEBUG_FLAGS)
m4_pattern_allow(CW_OPTIMISE_FLAGS)
m4_pattern_allow(CW_STRIPPED_CXXFLAGS)

# Add args to configure
AC_ARG_ENABLE(debug,         [  --enable-debug          build for debugging @<:@no@:>@])
AC_ARG_ENABLE(libcwd,        [  --enable-libcwd         link with libcwd @<:@auto@:>@])
AC_ARG_ENABLE(optimise,      [  --enable-optimise       do code optimization @<:@auto@:>@])
AC_ARG_ENABLE(profile,       [  --enable-profile        add profiling code @<:@no@:>@])

# Strip possible -g and -O commandline options from CXXFLAGS.
CW_DEBUG_FLAGS=
CW_OPTIMISE_FLAGS=
CW_STRIPPED_CXXFLAGS=
for arg in $CXXFLAGS; do
case "$arg" in # (
-g*)
        CW_DEBUG_FLAGS="$CW_DEBUG_FLAGS $arg"
        ;; # (
-O*)
        CW_OPTIMISE_FLAGS="$CW_OPTIMISE_FLAGS $arg"
        ;; # (
*)
        CW_STRIPPED_CXXFLAGS="$CW_STRIPPED_CXXFLAGS $arg"
        ;;
esac
done
CXXFLAGS="$CW_STRIPPED_CXXFLAGS"

# Set various defaults, depending on other options.

if test x"$enable_optimise" = x"no"; then
    CW_OPTIMISE_FLAGS=""        # Explicit --disable-optimise, strip optimization even from CXXFLAGS environment variable.
fi

if test x"$enable_maintainer_mode" = x"yes"; then
  if test -z "$enable_optimise"; then
    enable_optimise=no          # --enable-maintainer-mode, set default to --disable-optimise.
  fi
fi

if test x"$enable_debug" = x"yes"; then
  if test -z "$enable_optimise"; then
    enable_optimise=no          # --enable-debug and no --enable-optimise, set default to --disable-optimise.
  fi
else
  if test -z "$enable_libcwd"; then
    enable_libcwd=no            # No --enable-debug and no --enable-libcwd, set default to --disable-libcwd.
  fi
fi

# Handle enable_libcwd.
# Check if we have libcwd, $enable_libcwd can be "yes", "no" or "".
CW_LIB_LIBCWD([libcwd], [$enable_libcwd], [no])
USE_LIBCWD="$cw_used_libcwd"
AC_SUBST([USE_LIBCWD])
if test "$cw_used_libcwd" = "yes"; then
  test -n "$CW_DEBUG_FLAGS" || CW_DEBUG_FLAGS="-g"
  if test -z "$enable_optimise"; then
    enable_optimise=no          # libcwd is being used, set default to --disable-optimise.
  fi
  DOXYGEN_CWDEBUG=CWDEBUG
else
  DOXYGEN_CWDEBUG=
fi
AC_SUBST([DOXYGEN_CWDEBUG])

# Handle enable_debug.
if test x"$enable_debug" = x"yes"; then
  CXXFLAGS="$CXXFLAGS -W -Wall -Wundef -DDEBUG"
  DOXYGEN_DEBUG=DEBUG
  test -n "$CW_DEBUG_FLAGS" || CW_DEBUG_FLAGS="-g"
else
  DOXYGEN_DEBUG=
fi
AC_SUBST([DOXYGEN_DEBUG])

# Handle enable_optimise; when not explicitly set to "no", use user provided
# optimization flags, or -O2 when nothing was provided.
if test x"$enable_optimise" != x"no"; then
  test -n "$CW_OPTIMISE_FLAGS" || CW_OPTIMISE_FLAGS="-O2"
fi

# Handle enable_profile.
if test x"$enable_profile" = x"yes"; then
  CXXFLAGS="$CXXFLAGS -pg"
  LDFLAGS="$LDFLAGS -pg"
fi

# Reassemble CXXFLAGS with debug and optimization flags.
[CXXFLAGS=`echo "$CW_DEBUG_FLAGS $CW_OPTIMISE_FLAGS $CXXFLAGS" | sed -e 's/^ *//' -e 's/  */ /g' -e 's/ *$//'`]

dnl Put CXXFLAGS into the Makefile too
AC_SUBST(CXXFLAGS)
])
