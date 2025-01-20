#!/usr/bin/env bash
# This script downloads the source archive of SLiM, extracts it, creates a build
# directory and builds the command-line utilities for slim and eidos, and also
# the SLiMgui IDE. It then installs them to /usr/bin, and installs the
# FreeDesktop files to the appropriate places for desktop integration.

# Copyright © 2024 Bryce Carson
# Script released under the terms of the GNU GPL v3.0, or (at your option) a
# later version.

# Please report issues and submit pull requests against the SLiM-Extras GitHub
# repo, tagging Bryce.

synopsis() {
  echo "DebianUbuntuInstall.sh \
  Include the i option to automatically install missing dependencies (requires root). \
  Include the p option to specify an installation PREFIX, or use an environment variable PREFIX. This argument value will take precedence over the environment variable if both are exist. \
  Include the v option to enable shell-level verbosity (i.e. 'set -x'). \
  Include the h option to print this synopsis. \
\n\
  Each option has a corresponding long option. The compatible short options may be combined (e.g. 'DebianUbuntuInstall.sh -vip ~/.local') \
  -v | --verbose \
  -i | --install-dependencies \
  -p | --prefix ~/.local, exempli gratia \
  -h | --help"
}

# Modified from Keith Thompson's answer here: https://stackoverflow.com/a/17752318.
if [ ! "$BASH_VERSION" ]; then
  echo "Please do not use sh to run this script ($0); \
  execute the script with the following syntax:\
\
  ./$0" 1>&2;
  exit 1;
fi

build-and-install-SLiMgui-on-Debian-or-Ubuntu() {
  # Make shell options local to this function, and yap; when the function exits
  # the shell will stop yapping, unless it was already yapping before entering
  # this function.
  local -
  if $VERBOSE; then set -x; fi

  ## TEST WRITE ACCESS
  IFS=:;
  ## MAYBE FIXME: is the empty string a null-terminator for PATH, or a syntax
  ## mistake and PATH should be quoted? I don't know right now.
  for p in $PATH""; do
    [ -w "${p:-.}" ] || {
      [ "${PREFIX}/bin" = "$p" ] && {
        echo "${PREFIX} not writable, but in the PATH variable. You likely need \
        to become root or use sudo." | fold;
        exit 15;
      }
    };
  done
  
  if [ ! -w "$PREFIX" ]; then echo "${PREFIX} is not writable."; exit 99; fi

  ## DEPENDENCY DETECTION
  # Declare the local variable QT_PKGNAME
  if grep -E "(11)|(bullseye/sid)" /etc/debian_version; then {
    local QT_PKGNAME="qtbase5-dev";
    local QMAKE_PKGNAME="qt5-qmake";
    # Redefine QT_PKGNAME if the system is Debian and backports is enabled.
    if grep "Vendor: Debian" /etc/dpkg/origins/default; then {
      if grep "^[^#]*backport*" /etc/apt/sources.list; then
        QT_PKGNAME="qt6-base-dev";
        QMAKE_PKGNAME="qmake6";
      fi
    }
    fi
  }
  else
    local QT_PKGNAME="qt6-base-dev";
    local QMAKE_PKGNAME="qmake6";
  fi
  
  local REQUIRED_PACKAGES_INSTALLED=0;
  for PKG_NAME in build-essential cmake ${QMAKE_PKGNAME} qtchooser ${QT_PKGNAME};
  do
    # Increment the counter if the package is installed, otherwise report that it is
    # missing.
    if dpkg-query -s "$PKG_NAME" 2>/dev/null | \
        grep -q "^Status: install ok installed$"; then
      echo "Required package ${PKG_NAME} installed? YES";
      (( REQUIRED_PACKAGES_INSTALLED+=1 ));
    else
      echo "Required package ${PKG_NAME} installed? NO";
    fi
  done
  
  if [[ ${REQUIRED_PACKAGES_INSTALLED} -ne 5 ]]; then
    if [ "$(id -u)" -eq 0 ]; then
      # If the user is root install the missing package(s) on their behalf, if they wish.
      if $INSTALL_DEPS; then
        apt-get install --assume-yes cmake ${QMAKE_PKGNAME} qtchooser $QT_PKGNAME;
      fi
    else
      echo "A required package is missing. \
          Install the missing package(s) with 'sudo apt install PACKAGE'. \
          EXIT 1"; exit 1;
    fi
  fi
  
  # Create a temporary directory and change to it to proceed  with building.
  pushd "$(mktemp -d)" || {
    echo \
      "The Filesystem Hierarchy-standard directory /tmp does not exist, \
  $TMPDIR is not set, or some strange permissions issue exists with root and \
  one of these locations. Resolve the issue by creating that directory; \
  inspect this script, and your system, as other issues may exist." | \
      fold -sw 80;
    exit 3;
  }

  ## DOWNLOAD AND DECOMPRESS SOURCES
  local queryResponse=`mktemp`;
  wget -q -O- 'https://api.github.com/repos/MesserLab/SLiM/releases/latest' > $queryResponse
  wget "`awk '/tarball_url/ { split($0, arr, \"\\"\"); print(arr[4]); }' $queryResponse`" || {
    echo "Failed to download latest tagged release tarball, or decompress and unarchive it.";
    exit 4;
  }
  local version=`awk '/tag_name/ { split($0, arr, "\""); print(arr[4]); }' $queryResponse`
  tar -x -f ${version} && \
    find -D exec \
         $(dirs | cut --delimiter=" " --field 1) \
         -type d \
         -name "MesserLab-SLiM-*" -execdir mv '{}' SLiM \;;

  ## BUILD AND INSTALL
  # Proceed with building and installing if all tests succeeded.
  {  mkdir BUILD && pushd BUILD; } || {
    echo "Unable to create '$(pwd)/BUILD' due to a permissions error."
    exit 7;
  }
  
  # The build process cmake will follow when building SLiMgui will install desktop
  # integration files when the version of CMake is new enough, otherwise it will
  # not.
  { cmake -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
          -DBUILD_SLIMGUI=ON ../SLiM && make -j"$(nproc)"; } || {
    local logfile;
    logfile="/var/log/SLiM-CMakeOutput-$(date -Is).log";
    echo "Attempting to move logfile to permanent location."
    if [[ -d /var/log && -w "$logfile" && -d CMakeFiles ]]; then
      mv CMakeFiles/CMakeOutput.log "$logfile" || exit 8;
    else
      echo "${logfile} is not writable, writing to ~ instead."
      logfile="${HOME}/SLiM-CMakeOutput-$(date -Is).log";
      mv CMakeFiles/CMakeOutput.log "$logfile" || exit 8;
    fi;
    printf "Build failed. Please see the output and make a post on the \
  slim-discuss mailing list. The output from this build is stored in '/var/log/' \
  as %s. You may be asked to upload this file during a support request." "$logfile" \
      | fold -sw 80;
    exit 9;
  }
  make install
  
  if [ ../SLiM/data/applications/org.messerlab.slimgui.desktop \
                -nt ${PREFIX}/bin/slim ]; then
    {
      { mkdir -p ${PREFIX}/bin ${PREFIX}/share/icons/hicolor/scalable/apps/ \
              ${PREFIX}/share/icons/hicolor/scalable/mimetypes ${PREFIX}/share/mime/packages \
              ${PREFIX}/share/applications ${PREFIX}/share/metainfo/; } || {
        echo "Some directory necessary for installation was not successfully \
      created. Please see the output and make a post on the slim-discuss mailing \
      list." | fold -sw 80;
        exit 10;
      }
  
      cp -ant ${PREFIX}/share ../SLiM/data/* || {
        # Exit if installation unsuccessful.
        echo "cp -ant failed!";
        exit 14;
      }
  
      update-mime-database -n ${PREFIX}/mime/;
      xdg-mime install --mode system \
               ${PREFIX}/share/mime/packages/org.messerlab.slimgui-mime.xml;
    } || {
      echo "Desktop integration failed using 'cp -ant'. Please see the output \
      and make an issue on the SLiM-Extras GitHub repository." | fold -sw 80;
      exit 12;
    }
  
    for file in \
      ${PREFIX}/bin/eidos \
               ${PREFIX}/bin/slim \
               ${PREFIX}/bin/SLiMgui \
               ${PREFIX}/share/applications/org.messerlab.slimgui.desktop \
               ${PREFIX}/share/icons/hicolor/scalable/apps/org.messerlab.slimgui.svg \
               ${PREFIX}/share/icons/hicolor/scalable/mimetypes/text-slim.svg \
               ${PREFIX}/share/icons/hicolor/symbolic/apps/org.messerlab.slimgui-symbolic.svg \
               ${PREFIX}/share/metainfo/org.messerlab.slimgui.appdata.xml \
               ${PREFIX}/share/metainfo/org.messerlab.slimgui.metainfo.xml \
               ${PREFIX}/share/mime/packages/org.messerlab.slimgui-mime.xml
    do
      if [ ! -f $file ]; then
        echo "$file was not installed correctly.";
        exit 42;
      else
        echo "$file was installed correctly.";
      fi
    done
  fi
}

TEMP=$(getopt -o vihp: --long verbose,install-dependencies,prefix: -n 'DebianUbuntuInstall.sh' -- "$@")
if [ $? != 0 ]; then
  echo "getopts(1) failed to canonicalize arguments; terminating..." >&2;
  exit 1;
fi

eval set -- "$TEMP"

VERBOSE=false;
INSTALL_DEPS=false;
PREFIX=${PREFIX:-"/usr"}

while true; do
  case $1 in
    -v|--verbose) echo "Enabling verbose mode."; VERBOSE=true; shift;;
    -i|--install-dependencies) INSTALL_DEPS=true; shift;;
    -p|--prefix) PREFIX=$2; shift 2;;
    -h|--help) synopsis; exit;;
    *) break;;
  esac
done

build-and-install-SLiMgui-on-Debian-or-Ubuntu
