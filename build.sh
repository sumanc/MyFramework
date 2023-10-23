#!/bin/bash
BASE=`pwd`
CONFIG=Release

usage()
{
cat << EOF

usage: $0 [options]

This script builds MyFramework.xcframework

options:
   -h   Show this message
   -c   Build configuration. [Release | Debug]. Defaults to Release
EOF
exit -1;
}

while getopts “c:h” OPTION
do
     case $OPTION in
         h)
             usage
             ;;      
         c)
            CONFIG=$OPTARG
            ;;
     esac
done

DEST=Deliverables/$CONFIG
rm -rf $DEST
rm -rf DerivedData

mkdir -p $DEST
mkdir -p DerivedData

SYMROOT=DerivedData/Build/Products
BUILD_OPTIONS=" -configuration $CONFIG UFW_ACTION=archive build DEPLOYMENT_POSTPROCESSING=YES SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES -derivedDataPath DerivedData"

if [[ $CONFIG == "Debug" ]]; then
   BUILD_OPTIONS="${BUILD_OPTIONS} STRIP_INSTALLED_PRODUCT=NO SEPARATE_STRIP=NO COPY_PHASE_STRIP=NO"
fi


function doBuild() {
   echo "### Building $1"

   cd $BASE
   xcodebuild ONLY_ACTIVE_ARCH=NO GCC_PREPROCESSOR_DEFINITIONS='$GCC_PREPROCESSOR_DEFINITIONS' -scheme $1 -destination="generic/platform=iOS Simulator" -sdk iphonesimulator $BUILD_OPTIONS CONFIGURATION_BUILD_DIR=$SYMROOT/$CONFIG-iphonesimulator
   xcodebuild GCC_PREPROCESSOR_DEFINITIONS='$GCC_PREPROCESSOR_DEFINITIONS' -scheme $1 -destination="generic/platform=iOS" -sdk iphoneos $BUILD_OPTIONS CONFIGURATION_BUILD_DIR=$SYMROOT/$CONFIG-iphoneos

   cd $BASE/$DEST
   mkdir MyFramework

   cd MyFramework
   xcodebuild -create-xcframework \
        -framework $BASE/DerivedData/Build/Products/$CONFIG-iphonesimulator/MyFramework.framework \
        -framework $BASE/DerivedData/Build/Products/$CONFIG-iphoneos/MyFramework.framework \
        -output MyFramework.xcframework

   cd $BASE/$DEST/MyFramework
   touch Build-Info.txt
   echo "Built with Xcode $XCODE_VERSION" >> Build-Info.txt
   echo "Built on $(date)" >> Build-Info.txt

   cd $BASE

   echo ""
   echo "### Done building $1"
   echo ""
}

doBuild "MyFramework"



