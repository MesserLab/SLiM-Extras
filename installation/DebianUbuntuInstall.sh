#!/bin/bash
# This script downloads the source archive of SLiM, extracts it, creates a build
# directory and builds the command-line utilities for slim and eidos, and also
# the SLiMgui IDE. It then installs them to ${PREFIX}/bin, and installs the
# FreeDesktop files to the appropriate places for desktop integration.

# Copyright © 2024 Bryce Carson

# Please report issues and submit pull requests against the SLiM-Extras GitHub
# repo, tagging Bryce.

if [ $# -ge 1 ]; then
	echo "Using first argument as PREFIX for install, and assuming it is accessible by the current user.";
	echo "Determining if the PREFIX is writable and on PATH.";
	PREFIX=$1;
	sh -fc 'IFS=:; for p in $PATH""; do [ -w "${p:-.}" ] && {
	   [ ${PREFIX}="$p" ] || { echo "PREFIX not writable && on PATH"; exit 15; }
        }; done'
elif [ "$(id -u)" -ne 0 ]; then
	# We need superuser privileges.
	echo "No PREFIX specified in \$1, using PREFIX=/usr."
	PREFIX=/usr
        echo 'This script must be run by root' >&2
	echo "Invoke the script with sudo."
        exit 1
fi

# Test that build requirements are satisfied. If any one requirement is unmet we
# say which. Unset the variables before running to prevent confusion from earlier runs.
unset cmakeinstalled qmakeinstalled qtchooserinstalled qtbase5devinstalled \
      curlinstalled wgetinstalled;

# Test if CMake is installed
dpkg-query -s cmake 2>/dev/null | grep -q ^"Status: install ok installed"$;
cmakeinstalled=$?

# Test if qmake is installed.
dpkg-query -s qt5-qmake 2>/dev/null | grep -q ^"Status: install ok installed"$;
qmakeinstalled=$?

# Test if qtchoosre is installed.
dpkg-query -s qtchooser 2>/dev/null | grep -q ^"Status: install ok installed"$;
qtchooserinstalled=$?

# Test if qtbase5-dev library is installed.
dpkg-query -s qtbase5-dev 2>/dev/null | grep -q ^"Status: install ok installed"$;
qtbase5devinstalled=$?

# Test if curl is installed.
dpkg-query -s curl 2>/dev/null | grep -q ^"Status: install ok installed"$;
curlinstalled=$?

# Test if wget is installed.
dpkg-query -s wget 2>/dev/null | grep -q ^"Status: install ok installed"$;
wgetinstalled=$?

[[ $qmakeinstalled == 0 && \
       $qtchooserinstalled == 0 && \
       $qtbase5devinstalled == 0 ]] || {
    echo "All of: qt5-qmake, qtchooser, and qtbase5-dev must be installed. \
Install the Qt5 requirements with 'sudo apt install qtbase5-dev qtchooser \
qt5-qmake'. Installing these packages ensures all build and runtime \
requirements are satisfied." | fold -sw 80;
}

[[ $cmakeinstalled == 0 ]] || {
    echo "cmake is not installed. Install it with 'sudo apt install cmake'.";
}

[[ $curlinstalled == 0 || $wgetinstalled == 0 ]] || {
    echo "Neither curl nor wget are installed. Install either with one \
of: 'sudo apt install wget', OR 'sudo apt install curl'." | fold -sw 80;
}

#Exit if qtchooser, qtbase5-dev, qt5-qmake, or cmake are not installed. If
#neither curl nor wget are installed, we exit later.
[[ $qtchooserinstalled == 0 && $qtbase5devinstalled == 0 && \
       $qmakeinstalled == 0 && $cmakeinstalled == 0 ]] || exit 2;

pushd `mktemp -d` || {
    echo "The Filesystem Hierarchy-standard directory /tmp does not exist, \
\$TMPDIR is not set, or some strange permissions issue exists with root and \
one of these locations. Resolve the issue by creating that directory; \
inspect this script, and your system, as other issues may exist." | fold -sw 80;
    exit 3;
}

if [[ $curlinstalled == 0 ]]; then
    { curl -L https://github.com/MesserLab/SLiM/archive/refs/tags/v4.2.2.tar.gz > \
           SLiM-4.2.2.tar.gz && tar -x -f SLiM-4.2.2.tar.gz && \
          mv SLiM-4.2.2 SLiM;
    } || {
        printf "Failed to download %s%s as SLiM-4.2.2.tar.gz or decompress and \
unarchive it." 'https://github.com/MesserLab/SLiM/archive/refs/tags/' \
               'v4.2.2.tar.gz';
        exit 4;
    }
elif [[ $wgetinstalled == 0 ]]; then
	  { wget https://github.com/MesserLab/SLiM/archive/refs/tags/v4.2.2.tar.gz && \
          tar -x -f v4.2.2.tar.gz && mv SLiM-4.2.2 SLiM; } || {
        printf "Failed to download %s%s or decompress and unarchive it." \
               'https://github.com/MesserLab/SLiM/archive/refs/tags/' \
               'v4.2.2.tar.gz';
        exit 5;
    }
else { exit 6; } # Exit if neither curl nor wget is installed.
fi

# Write out the patch:
{ cat <<'EOF' > CMakeLists.patch
diff --git a/CMakeLists.txt b/CMakeLists.txt
index d278da11..1bd308d8 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -57,7 +57,10 @@ cmake_minimum_required (VERSION 2.8.12 FATAL_ERROR)
 option(TIDY "Run clang-tidy on SLiM (for development)" OFF)
 
 if(TIDY)
-	cmake_minimum_required(VERSION 3.6 FATAL_ERROR)
+	# cmake_minimum_required(VERSION 3.6 FATAL_ERROR)
+  if(CMAKE_VERSION VERSION_LESS "3.6")
+    message(FATAL_ERROR "To use the clang-tidy wrapper TIDY in this project you will need a version of CMake at least as new as 3.6.")
+  endif()
 	message(STATUS "TIDY is ${TIDY}; building with clang-tidy (for development)")
 	set(CMAKE_C_COMPILER "/opt/local/libexec/llvm-17/bin/clang")
 	set(CMAKE_CXX_COMPILER "/opt/local/libexec/llvm-17/bin/clang++")
@@ -318,41 +321,51 @@ endif(PARALLEL)
 
 # SLiMgui -- this can be enabled with the -DBUILD_SLIMGUI=ON option to cmake
 if(BUILD_SLIMGUI)
-cmake_minimum_required (VERSION 3.1.0 FATAL_ERROR)
-set(TARGET_NAME SLiMgui)
-find_package(OpenGL REQUIRED)
-find_package(Qt5 REQUIRED
+  cmake_minimum_required (VERSION 3.1.0 FATAL_ERROR)
+  set(TARGET_NAME SLiMgui)
+  find_package(OpenGL REQUIRED)
+  find_package(Qt5 REQUIRED
     Core
     Gui
     Widgets
-)
-if(WIN32)
+  )
+
+  if(WIN32)
     set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/${TARGET_NAME}_autogen/mocs_compilation.cpp" PROPERTIES COMPILE_FLAGS "-include config.h -DGNULIB_NAMESPACE=gnulib")
-endif()
-set(CMAKE_AUTOMOC ON)
-set(CMAKE_AUTORCC ON)
-set(CMAKE_AUTOUIC ON)
-list(REMOVE_ITEM SLIM_SOURCES ${PROJECT_SOURCE_DIR}/core/main.cpp)
-file(GLOB_RECURSE QTSLIM_SOURCES ${PROJECT_SOURCE_DIR}/QtSLiM/*.cpp ${PROJECT_SOURCE_DIR}/QtSLiM/*.qrc ${PROJECT_SOURCE_DIR}/eidos/*.cpp)
-add_executable(${TARGET_NAME} "${QTSLIM_SOURCES}" "${SLIM_SOURCES}")
-set_target_properties( ${TARGET_NAME} PROPERTIES LINKER_LANGUAGE CXX)
-target_compile_definitions( ${TARGET_NAME} PRIVATE EIDOSGUI=1 SLIMGUI=1)
-target_include_directories(${TARGET_NAME} PUBLIC ${GSL_INCLUDES} "${PROJECT_SOURCE_DIR}/QtSLiM" "${PROJECT_SOURCE_DIR}/eidos" "${PROJECT_SOURCE_DIR}/core" "${PROJECT_SOURCE_DIR}/treerec" "${PROJECT_SOURCE_DIR}/treerec/tskit/kastore")
-if(APPLE)
-	target_link_libraries( ${TARGET_NAME} PUBLIC Qt5::Widgets Qt5::Core Qt5::Gui OpenGL::GL gsl tables eidos_zlib )
-else()
+  endif()
+
+  set(CMAKE_AUTOMOC ON)
+  set(CMAKE_AUTORCC ON)
+  set(CMAKE_AUTOUIC ON)
+  list(REMOVE_ITEM SLIM_SOURCES ${PROJECT_SOURCE_DIR}/core/main.cpp)
+  file(GLOB_RECURSE QTSLIM_SOURCES ${PROJECT_SOURCE_DIR}/QtSLiM/*.cpp ${PROJECT_SOURCE_DIR}/QtSLiM/*.qrc ${PROJECT_SOURCE_DIR}/eidos/*.cpp)
+  add_executable(${TARGET_NAME} "${QTSLIM_SOURCES}" "${SLIM_SOURCES}")
+  set_target_properties( ${TARGET_NAME} PROPERTIES LINKER_LANGUAGE CXX)
+  target_compile_definitions( ${TARGET_NAME} PRIVATE EIDOSGUI=1 SLIMGUI=1)
+  target_include_directories(${TARGET_NAME} PUBLIC ${GSL_INCLUDES} "${PROJECT_SOURCE_DIR}/QtSLiM" "${PROJECT_SOURCE_DIR}/eidos" "${PROJECT_SOURCE_DIR}/core" "${PROJECT_SOURCE_DIR}/treerec" "${PROJECT_SOURCE_DIR}/treerec/tskit/kastore")
+
+  # Operating System-specific install stuff.
+  if(APPLE)
+	  target_link_libraries( ${TARGET_NAME} PUBLIC Qt5::Widgets Qt5::Core Qt5::Gui OpenGL::GL gsl tables eidos_zlib )
+  else()
     if(WIN32)
-        set_source_files_properties(${QTSLIM_SOURCES} PROPERTIES COMPILE_FLAGS "-include config.h")
-        set_source_files_properties(${GNULIB_NAMESPACE_SOURCES} TARGET_DIRECTORY slim eidos SLiMgui PROPERTIES COMPILE_FLAGS "-include config.h -DGNULIB_NAMESPACE=gnulib")
-        target_include_directories(${TARGET_NAME} BEFORE PUBLIC ${GNU_DIR})
-        target_link_libraries(${TARGET_NAME} PUBLIC Qt5::Widgets Qt5::Core Qt5::Gui OpenGL::GL gsl tables eidos_zlib gnu )
+      set_source_files_properties(${QTSLIM_SOURCES} PROPERTIES COMPILE_FLAGS "-include config.h")
+      set_source_files_properties(${GNULIB_NAMESPACE_SOURCES} TARGET_DIRECTORY slim eidos SLiMgui PROPERTIES COMPILE_FLAGS "-include config.h -DGNULIB_NAMESPACE=gnulib")
+      target_include_directories(${TARGET_NAME} BEFORE PUBLIC ${GNU_DIR})
+      target_link_libraries(${TARGET_NAME} PUBLIC Qt5::Widgets Qt5::Core Qt5::Gui OpenGL::GL gsl tables eidos_zlib gnu )
     else()
 	    target_link_libraries( ${TARGET_NAME} PUBLIC Qt5::Widgets Qt5::Core Qt5::Gui OpenGL::GL gsl tables eidos_zlib )
-        # Install icons and desktop files to the data root directory (usually /usr/local/share, or /usr/share).
-	    install(DIRECTORY data/ TYPE DATA)
-    endif() 
-endif()
-install(TARGETS ${TARGET_NAME} DESTINATION bin)
+
+      # Install icons and desktop files to the data root directory (usually /usr/local/share, or /usr/share).
+      if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.14")
+        install(DIRECTORY data/ TYPE DATA)
+      else()
+        message(WARNING "The CMake version is less than 3.14, so installation of icons, desktop files, mime types, etc. must occur manually.")
+      endif()
+    endif()
+  endif()
+
+  install(TARGETS ${TARGET_NAME} DESTINATION bin)
 endif(BUILD_SLIMGUI)
 
 
EOF
} && patch -f --verbose -p0 SLiM/CMakeLists.txt CMakeLists.patch || {
    echo "Patching CMakeLists.txt to prevent issue #441 failed. That makes this \
error a new issue! Lucky you!, with lucky (exit) number thirteen in addition to \
this fact!";
    exit 13;
}

# Proceed with building and installing if all tests succeeded.
{  mkdir BUILD && pushd BUILD; } || {
    echo "Root is unable to create `pwd`/BUILD. This is a strange permissions \
error." | fold -sw 80;
    exit 7;
}

# The build process cmake will follow when building SLiMgui will install desktop
# integration files when the version of CMake is new enough, otherwise it will
# not.
{ cmake -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
        -DBUILD_SLIMGUI=ON ../SLiM && make -j"$(nproc)"; } || {
    logfile="/var/log/SLiM-CMakeOutput-$(date -Is).log";
    echo "Attempting to move logfile to permanent location."
    if [[ -d /var/log && -d CMakeFiles ]]; then
        mv CMakeFiles/CMakeOutput.log $logfile || exit 8;
    fi;
    printf "Build failed. Please see the output and make a post on the \
slim-discuss mailing list. The output from this build is stored in '/var/log/' \
as %s. You may be asked to upload this file during a support request." $logfile \
        | fold -sw 80;
    exit 9;
}

{ mkdir -p ${PREFIX}/bin ${PREFIX}/share/icons/hicolor/scalable/apps/ \
        ${PREFIX}/share/icons/hicolor/scalable/mimetypes ${PREFIX}/share/mime/packages \
        ${PREFIX}/share/applications ${PREFIX}/share/metainfo/; } || {
    echo "Some directory necessary for installation was not successfully \
created. Please see the output and make a post on the slim-discuss mailing \
list." | fold -sw 80;
    exit 10;
}

install slim eidos SLiMgui ${PREFIX}/bin || {
    echo "Installation to ${PREFIX}/bin was unsuccessful. Please see the output and \
make a post on the slim-discuss mailing list." | fold -sw 80;
    exit 11;
}


testversion=`mktemp`
cat <<EOF > ${testversion}
if(CMAKE_VERSION VERSION_LESS "3.14")
  message(WARNING "The following cmake error (generated with FATAL_ERROR messaging) was intentionally generated. It is used to generate a useful exit value from CMake, indicating if the CMake version on your system is new enough. The current implementation of DebianUbuntuInstall.sh depended on this. You may safely ignore that warning.")
  message(FATAL_ERROR "CMAKE_VERSION is less than 3.14; installing desktop files using cp, update-mime-database, and xdg-mime rather than CMake.")
endif()
EOF
cmake -P ${testversion};
recentcmake=$?;
if [[ $recentcmake -ne 0 ]]; then
    echo "Installation to ${PREFIX}/bin was successful. Proceeding with desktop \
integration." | fold -sw 80;
    { cp -ant ${PREFIX}/share ../SLiM/data/* || {
	  # Exit if installation unsuccessful.
	  echo "\`cp -ant\` failed!";
          exit 14;
      }
      update-mime-database -n ${PREFIX}/mime/;
      xdg-mime install --mode system \
               ${PREFIX}/share/mime/packages/org.messerlab.slimgui-mime.xml;
    } || {
        echo "Desktop integration failed. Please see the output and make a post
        on the slim-discuss mailing list." | fold -sw 80;
        exit 12;
    }

    echo "Desktop integration was successful.";
fi

popd || {
    echo "For some reason could not change to ~ before exiting script." | \
fold -sw 80;
}

echo "Installation successful!";
DebianUbuntuInstallTempDir=`pwd`; # The top of the directory stack.
