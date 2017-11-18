#!/bin/bash

INSTALL_PATH=$HOME/gcc-graph
if [ "$1" != "" ]; then INSTALL_PATH=$1; fi
if [ "$2" = "compile-only" ]; then export COMPILE_ONLY=yes; fi
echo Installing gcc to $INSTALL_PATH

NCFTP=`which ncftpget`
EXIT=$?
if [ "$EXIT" != "0" ]; then
  NCFTP=ftp
fi

if [ ! -e gcc-5.4.0.tar.gz ]; then
  echo gcc-5.4.0.tar.gz not found, downloading
  $NCFTP ftp://ftp.gnu.org/pub/gnu/gcc/gcc-5.4.0/gcc-5.4.0.tar.gz
  if [ ! -e gcc-5.4.0.tar.gz ]; then
    echo Failed to download gcc, download gcc-5.4.0.tar.gz from www.gnu.org
    exit
  fi
fi

# Untar gcc
rm -rf gcc-graph/objdir 2> /dev/null
mkdir -p gcc-graph/objdir
echo Untarring gcc...
tar -zxf gcc-5.4.0.tar.gz -C gcc-graph || exit
cd gcc-graph/objdir

# Configure and compile
#../gcc-5.4.0/configure --prefix=$INSTALL_PATH --with-system-zlib --disable-multilib --enable-languages=c,c++ --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu || exit
../gcc-5.4.0/configure --prefix=$INSTALL_PATH --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --enable-shared --disable-multilib --enable-languages=c,c++ || exit
make 

# Apply patch
cd ../gcc-5.4.0
patch -p1 < ../../gcc-patches/gcc-5.4.0-cdepn.diff
cd ../objdir
make #clean build of patched sources produces a relocation linker error

RETVAL=$?
if [ $RETVAL = 0 ]; then
  if [ "$COMPILE_ONLY" != "yes" ]; then
    make install
  fi
fi

