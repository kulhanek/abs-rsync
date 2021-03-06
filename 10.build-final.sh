#!/bin/bash

SITES="clusters"
PREFIX="core"

if [[ ! ( ( "`hostname -f`" == "deb8.ncbr.muni.cz" ) || ( "`hostname -f`" == *"salomon"* ) )  ]]; then
    echo "unsupported build machine!"
    exit 1
fi

set -o pipefail

# names ------------------------------
NAME="abs-rsync"
VERS="3.1.2"
ARCH=`uname -m`
MODE="single" 
echo "Build: $NAME:$VERS:$ARCH:$MODE"
echo ""

# ------------------------------------
if [ -z "$AMS_ROOT" ]; then
   echo "ERROR: This installation script works only in the Infinity environment!"
   exit 1
fi

# build and install software ---------
./configure --prefix="$SOFTREPO/$PREFIX/$NAME/$VERS/$ARCH/$MODE" 2>&1 | tee configure.log
if [ $? -ne 0 ]; then exit 1; fi

make 2>&1 | tee make.log
if [ $? -ne 0 ]; then exit 1; fi

make install 2>&1 | tee install.log
if [ $? -ne 0 ]; then exit 1; fi

# prepare build file -----------------
SOFTBLDS="$AMS_ROOT/etc/map/builds/$PREFIX"
VERIDX=`ams-map-manip newverindex $NAME:$VERS:$ARCH:$MODE`

cat > $SOFTBLDS/$NAME:$VERS:$ARCH:$MODE.bld << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!-- Advanced Module System (AMS) build file -->
<build name="$NAME" ver="$VERS" arch="$ARCH" mode="$MODE" verindx="$VERIDX">
    <setup>
        <variable name="AMS_PACKAGE_DIR" value="$PREFIX/$NAME/$VERS/$ARCH/$MODE" operation="set" priority="modaction"/>
        <variable name="ABS_RSYNC" value="\$SOFTREPO/$PREFIX/$NAME/$VERS/$ARCH/$MODE/bin/rsync" operation="set"/>
    </setup>
</build>
EOF
if [ $? -ne 0 ]; then exit 1; fi

echo ""
echo "Adding builds ..."
ams-map-manip addbuilds $SITES $NAME:$VERS:$ARCH:$MODE >> ams.log 2>&1
if [ $? -ne 0 ]; then echo ">>> ERROR: see ams.log"; exit 1; fi

echo "Distribute builds ..."
ams-map-manip distribute >> ams.log 2>&1
if [ $? -ne 0 ]; then echo ">>> ERROR: see ams.log"; exit 1; fi

echo "Rebuilding cache ..."
ams-cache rebuildall >> ams.log 2>&1
if [ $? -ne 0 ]; then echo ">>> ERROR: see ams.log"; exit 1; fi

echo "Log file: ams.log"
echo ""


