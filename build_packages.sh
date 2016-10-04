#!/bin/bash
# Build script for avdecc-lib, jdksavdecc-c, cpputest

# Variables
clean=$1
out_bin="../../target/usr/bin"
out_cpputest="$out_bin/open-avb-cpputest"

if [ "$1" != "" -a "$1" != "clean" ]; then
	echo "Usage: $0 clean"
	exit -1
fi

# Build for jdksavdecc-c
if [ ! -d "avdecc-lib/jdksavdecc-c" ]; then 
	echo "avdecc-lib/jdksavdecc-c directory doesn't exists"
	exit -1
fi

cd ./avdecc-lib/jdksavdecc-c/
cmake -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_TOOLCHAIN_FILE:PATH=../../../../host/usr/share/buildroot/toolchainfile.cmake \
	-DCMAKE_INSTALL_FREFIX=../../../../staging/usr/ .
make $clean
cd ../../

# Build for avdecc-lib
if [ ! -d "avdecc-lib" ]; then 
	echo "avdecc-lib directory doesn't exists"
	exit -1
fi

cd ./avdecc-lib/
cmake -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_TOOLCHAIN_FILE:PATH=../../../host/usr/share/buildroot/toolchainfile.cmake \
	-DCMAKE_INSTALL_FREFIX=../../../staging/usr/ .
make $clean
cd ../

# Build for cpputest
mkdir build

if [ ! -d "build" ]; then 
	echo "build directory doesn't exists"
	exit -1
fi

cd build

# Create makefiles by cmake 
cmake -DCMAKE_BUILD_TYPE=RELEASE \
	-DCMAKE_TOOLCHAIN_FILE:PATH=../../../host/usr/share/buildroot/toolchainfile.cmake \
	-DCMAKE_INSTALL_FREFIX=../../../staging/usr/ ..
make $clean
#make test
cd ../

# Install target
if [ ! -d "$out_bin/open-avb-cpputest" ]; then
	echo "cpputest dir : $out_cpputest"
	mkdir $out_cpputest
fi

if [ "$1" == "" ]; then
	echo "copy avdecc and cpputest files..."
	echo $out_bin
	echo $out_cpputest
	cp ./avdecc-lib/controller/app/cmdline/avdecccmdline $out_bin
	cp ./avdecc-lib/jdksavdecc-c/jdksavdecc-tool-gen-acmpdu $out_bin
	cp ./avdecc-lib/jdksavdecc-c/jdksavdecc-tool-print-pdu $out_bin
	cp ./build/daemons/common/tests/alltests $out_cpputest
	cp ./build/daemons/mrpd/mrpd $out_cpputest
	cp ./build/daemons/mrpd/tests/simple/mrpd_simple_test $out_cpputest
	cp ./build/thirdparty/cpputest/tests/CppUTestTests $out_cpputest
	cp ./build/thirdparty/cpputest/tests/CppUTestExt/CppUTestExtTests $out_cpputest
else
	echo "clean avdecc and cpputest files..."
	rm $out_bin/avdecccmdline
	rm $out_bin/jdksavdecc-tool-gen-acmpdu
	rm $out_bin/jdksavdecc-tool-print-pdu
	rm -rf $out_cpputest
fi

