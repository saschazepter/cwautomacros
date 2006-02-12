# CW_DO_OPTIONS m4 macro -- this file is part of cwautomacros.
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

dnl CW_DO_OPTIONS
dnl Chose reasonable default values for WARNOPTS, DEBUGOPTS and EXTRAOPTS
AC_DEFUN([CW_DO_OPTIONS], [dnl
dnl Choose warning options to use
if test "$USE_MAINTAINER_MODE" = yes; then
AC_EGREP_CPP(Winline-broken,
[#if __GNUC__ < 3
Winline-broken
#endif
],
WARNOPTS="-Wall -Woverloaded-virtual -Wundef -Wpointer-arith -Wwrite-strings -Werror",
WARNOPTS="-Wall -Woverloaded-virtual -Wundef -Wpointer-arith -Wwrite-strings -Werror -Winline")
else
WARNOPTS=
fi
AC_SUBST(WARNOPTS)

dnl Stop automake from adding the `-I. -I. -I.' nonsense
AC_SUBST(DEFS)

dnl Find out which debugging options we need
AC_CANONICAL_HOST
case "$host" in
  *freebsd*) DEBUGOPTS=-ggdb ;; dnl FreeBSD needs -ggdb to include sourcefile:linenumber info in its object files.
  *) DEBUGOPTS=-g ;;
esac
AC_SUBST(DEBUGOPTS)

AC_ARG_ENABLE(optimization,
    AC_HELP_STRING([--enable-optimization], [enable optimization @<:@default=!maintainermode@:>@.]),
    cw_config_optimization=$enableval)

dnl Other options
EXTRAOPTS=""
if test "$USE_MAINTAINER_MODE" = yes; then
  if test x"$cw_config_optimization" = x"yes"; then
    EXTRAOPTS="-O3"
  fi
elif test x"$cw_config_optimization" != x"no"; then
  EXTRAOPTS="-O3"
fi
AC_SUBST(EXTRAOPTS)

dnl Test options
TESTOPTS=""
AC_SUBST(TESTOPTS)
])
