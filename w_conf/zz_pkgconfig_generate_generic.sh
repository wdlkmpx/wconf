#!/bin/sh
# Public Domain

if [ "$1" = "update" ] ; then
	cd $(dirname "$0")

	export zlist='../configure.project.etc'
	printf '#!/bin/sh' > ${zlist}

	CUSTOM_HEADER='alsa/version.h' CUSTOM_LIBS='-lasound' \
	$0 alsa       ALSA       alsa

	$0 glib       GLIB       glib-2.0

	$0 gthread    GTHREAD    gthread-2.0

	CUSTOM_HEADER='cdio/cdio.h' CUSTOM_LIBS='-lcdio' \
	$0 libcdio LIBCDIO libcdio

	CUSTOM_HEADER='dvdnav/dvdnav.h' CUSTOM_LIBS='-ldvdnav' \
	$0 libdvdnav LIBDVDNAV dvdnav

	CUSTOM_HEADER='dvdread/dvd_reader.h' CUSTOM_LIBS='-ldvdread' \
	$0 libdvdread LIBDVDREAD dvdread

	CUSTOM_HEADER='jpeglib.h' CUSTOM_LIBS='-ljpeg' \
	$0 libjpeg LIBJPEG libjpeg

	$0 libxml2 LIBXML2 libxml-2.0

	CUSTOM_CONFIG_SCRIPTS='ncursesw6-config ncursesw5-config ncurses6-config ncurses6-config' \
	CUSTOM_HEADER='ncurses.h' CUSTOM_LIBS='-lncursesw' \
	CUSTOM_HEADER2='ncurses.h' CUSTOM_LIBS2='-lncurses' \
	$0 ncurses    NCURSES    ncursesw ncurses

	CUSTOM_HEADER='openssl/ssl.h' CUSTOM_LIBS='-lssl -lcrypto' \
	$0 openssl    OPENSSL    openssl

	CUSTOM_HEADER='popt.h' CUSTOM_LIBS='-lpopt' \
	$0 popt       POPT       popt

	$0 pulse            PULSEAUDIO       libpulse
	$0 pulse_glib       PULSEAUDIO       libpulse-mainloop-glib

	CUSTOM_HEADER='readline/readline.h' CUSTOM_LIBS='-lreadline' \
	$0 readline   READLINE   readline

	# vte now has custom code
	#$0 vte   VTE   vte vte-2.91

	CUSTOM_HEADER='zlib.h' CUSTOM_LIBS='-lz' \
	$0 zlib       ZLIB       zlib
	exit
fi

#====================================================================

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] ; then
	echo "syntax1: $0 pkg PKG pkg_config"
	echo "syntax2: $0 update"
	exit
fi

#====================================================================

zw_pkg=$1
zw_env=$2
shift
shift
zw_pc=$@

if [ -f "$zw_pkg" ] ; then
	echo "Updating $zw_pkg"
else
	echo "Creating $zw_pkg"
fi

#====================================================================
# 

CCONFIG_TXT=''
CCONFIG_TXT2=''
CCONFIG_TXT3=''
CCONFIG_TXT4=''

if [ -n "$CUSTOM_CONFIG_SCRIPTS" ] ; then
	CCONFIG_TXT='
		if [ -z "$pcpkg" ]  && [ -z "${W_'${zw_env}'_MIN_VERSION}" ] ; then
			printf "Checking for '${zw_pkg}'... "
			pcpkg="$(check_command '${CUSTOM_CONFIG_SCRIPTS}')"
			if [ -n "$pcpkg" ] ; then
				echo "yes [$pcpkg]"
				'${zw_env}'_CFLAGS="$(${pcpkg} --cflags 2>/dev/null)"
				'${zw_env}'_LIBS="$(${pcpkg} --libs 2>/dev/null)"
			else
				echo "no"
			fi
		fi
		#--'
fi

if [ -n "$CUSTOM_HEADER" ] ; then
	CCONFIG_TXT2='
		if [ -z "$pcpkg" ]  && [ -z "${W_'${zw_env}'_MIN_VERSION}" ] ; then
			w_check_header_and_libs '${CUSTOM_HEADER}' '${CUSTOM_LIBS}'
			if [ $? -eq 0 ] ; then
				#'${zw_env}'_CFLAGS=...
				'${zw_env}'_LIBS="'${CUSTOM_LIBS}'"
				pcpkg=configure
			fi
		fi
		#--'
fi

if [ -n "$CUSTOM_HEADER2" ] ; then
	CCONFIG_TXT3='
		if [ -z "$pcpkg" ]  && [ -z "${W_'${zw_env}'_MIN_VERSION}" ] ; then
			w_check_header_and_libs '${CUSTOM_HEADER2}' '${CUSTOM_LIBS2}'
			if [ $? -eq 0 ] ; then
				#'${zw_env}'_CFLAGS=...
				'${zw_env}'_LIBS="'${CUSTOM_LIBS2}'"
				pcpkg=configure
			fi
		fi
		#--'
fi

#====================================================================

echo '#!/bin/sh
# Public Domain

# optional variables to set before sourcing this script
#
# - W_'${zw_env}'_IS_OPTIONAL=yes [show --disable-'${zw_pkg}' in --help msg]
# - W_'${zw_env}'_MIN_VERSION=xxx [minimun supported version, .pc file is required]
#

#=======================================
w_new_option '${zw_pkg}' '${zw_env}'
#=======================================

'${zw_pkg}'_pc_pkg="'${zw_pc}'"


opt_print_'${zw_pkg}'()
{
	if [ "$W_'${zw_env}'_IS_OPTIONAL" = "yes" ] ; then
		echo "  --disable-'${zw_pkg}'           do not build '${zw_env}' support (autodetect)"
	fi
}


opt_configure_'${zw_pkg}'()
{
	if [ "$W_'${zw_env}'_IS_OPTIONAL" = "yes" ] ; then
		enable_'${zw_pkg}'=check
	else
		enable_'${zw_pkg}'=yes
		return
	fi

	for i in $@
	do
		case $i in
		--enable-'${zw_pkg}')  enable_'${zw_pkg}'=yes ;;
		--disable-'${zw_pkg}') enable_'${zw_pkg}'=no ;;
		esac
	done
}


opt_check_'${zw_pkg}'()
{
	if [ "$enable_'${zw_pkg}'" = "no" ] ; then
		return
	fi

	if [ -n "$'${zw_env}'_CFLAGS" ] || [ -n "$'${zw_env}'_LIBS" ] ; then
		echo "Checking for '${zw_env}'... \$'${zw_env}'_CFLAGS/\$'${zw_env}'_LIBS"
	else
		pcpkg=
		for onepkg in ${'${zw_pkg}'_pc_pkg}
		do
			if w_pkgconfig_check ${onepkg} ${W_'${zw_env}'_MIN_VERSION} ; then
				pcpkg=${onepkg}
				break
			fi
		done
'"${CCONFIG_TXT}${CCONFIG_TXT2}${CCONFIG_TXT3}"'
		if [ -z "$pcpkg" ] ; then
			if [ "$enable_'${zw_pkg}'" = "yes" ] ; then
				exit_error "pkg-config: '${zw_pkg}' was not found"
			fi
			return
		fi
		if [ ! -f "$pcpkg" ] ; then
			# $pcpkg must not be a file, otherwise it is a custom xxx-config file
			'${zw_env}'_CFLAGS="$(run_pkg_config ${pcpkg} --cflags 2>/dev/null)"
			'${zw_env}'_LIBS="$(run_pkg_config ${pcpkg} --libs 2>/dev/null)"
		fi
	fi

	config_h_have="$config_h_have '${zw_env}'"
	config_mk_flags="$config_mk_flags '${zw_env}'"
}
' > ${zw_pkg}

#--

if [ -n "$zlist" ] ; then
	echo '
W_'${zw_env}'_IS_OPTIONAL=yes
#W_'${zw_env}'_MIN_VERSION=
include '${zw_pkg}'' >> ${zlist}
fi

