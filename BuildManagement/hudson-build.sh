#!/bin/sh

# BUILD SCRIPT FOR KOBOLD2D v2.x ...

BUILDTOOLXCODE43=/Applications/Xcode43.app/Contents/Developer/usr/bin/xcodebuild
BUILDTOOLXCODE44=/Applications/Xcode_previous_versions/Xcode44.app/Contents/Developer/usr/bin/xcodebuild
BUILDTOOLXCODE45=/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild
KKROOT=/depot-kobold2d/Kobold2D-2.x-Master/Kobold2D/
KKWORKSPACEFILE=Kobold2D.xcworkspace
KKWORKSPACE=${KKROOT}${KKWORKSPACEFILE}

# remove 2.x prefix
JOB_NAME=${JOB_NAME:3}
# bash has got to be the most ridiculous way to perform upper/lowercase conversions
JOB_NAME_LOWERCASE="$(echo ${JOB_NAME} | tr 'A-Z' 'a-z')"

echo Building project: $JOB_NAME

# rename derived data folder for this build job
DERIVED=___DerivedData
DERIVED=/depot-kobold2d/${DERIVED}
DERIVED_XCODE43=${DERIVED}_XCODE43-2.x
DERIVED_XCODE44=${DERIVED}_XCODE44-2.x
DERIVED_XCODE45=${DERIVED}_XCODE45-2.x

function failed()
{
    echo "Failed: $@" >&2
    
	if [ "$XCODE" -eq 45 ]; then
		mv ${DERIVED} ${DERIVED_XCODE45}
	fi
	if [ "$XCODE" -eq 44 ]; then
		mv ${DERIVED} ${DERIVED_XCODE44}
	fi
	if [ "$XCODE" -eq 43 ]; then
		mv ${DERIVED} ${DERIVED_XCODE43}
	fi
    
    exit 1
}

set -ex

COMMON_ARGS="-workspace $KKWORKSPACE -scheme $JOB_NAME ONLY_ACTIVE_ARCH=NO GCC_TREAT_WARNINGS_AS_ERRORS=YES"


if [ -d ${DERIVED} ]; then
	rm -rfd ${DERIVED}
fi


# Xcode 4.5
XCODE=45
if [ -d ${DERIVED_XCODE45} ]; then
	mv ${DERIVED_XCODE45} ${DERIVED}
fi

case $JOB_NAME_LOWERCASE in
     *-ios) 
    	 echo "============ RUNNING IOS BUILDS ============"
		$BUILDTOOLXCODE45 $COMMON_ARGS -sdk iphoneos -configuration Release || failed IPHONEOS-RELEASE_XCODE45
		$BUILDTOOLXCODE45 $COMMON_ARGS -sdk iphoneos -configuration Debug || failed IPHONEOS-DEBUG_XCODE45
		$BUILDTOOLXCODE45 $COMMON_ARGS VALID_ARCHS=i386 ARCHS=i386 GCC_VERSION=com.apple.compilers.llvm.clang.1_0.compiler -sdk iphonesimulator -configuration Debug || failed IPHONESIMULATOR-DEBUG_XCODE45
     ;;
     *-mac) 
 	    echo "============ RUNNING MAC OS BUILDS ============"
		$BUILDTOOLXCODE45 $COMMON_ARGS -sdk macosx -configuration Release || failed MACOSX-RELEASE_XCODE45
		$BUILDTOOLXCODE45 $COMMON_ARGS -sdk macosx -configuration Debug || failed MACOSX-DEBUG_XCODE45
     ;;
esac

# keep the build folder for the next run
mv ${DERIVED} ${DERIVED_XCODE45}


# Xcode 4.4
XCODE=44
if [ -d ${DERIVED_XCODE44} ]; then
	mv ${DERIVED_XCODE44} ${DERIVED}
fi

case $JOB_NAME_LOWERCASE in
     *-ios) 
    	 echo "============ RUNNING IOS BUILDS ============"
		$BUILDTOOLXCODE44 $COMMON_ARGS -sdk iphoneos -configuration Release || failed IPHONEOS-RELEASE_XCODE44
		$BUILDTOOLXCODE44 $COMMON_ARGS -sdk iphoneos -configuration Debug || failed IPHONEOS-DEBUG_XCODE44
		$BUILDTOOLXCODE44 $COMMON_ARGS VALID_ARCHS=i386 ARCHS=i386 GCC_VERSION=com.apple.compilers.llvm.clang.1_0.compiler -sdk iphonesimulator -configuration Debug || failed IPHONESIMULATOR-DEBUG_XCODE44
     ;;
     *-mac) 
 	    echo "============ RUNNING MAC OS BUILDS ============"
		$BUILDTOOLXCODE44 $COMMON_ARGS -sdk macosx -configuration Release || failed MACOSX-RELEASE_XCODE44
		$BUILDTOOLXCODE44 $COMMON_ARGS -sdk macosx -configuration Debug || failed MACOSX-DEBUG_XCODE44
     ;;
esac

# keep the build folder for the next run
mv ${DERIVED} ${DERIVED_XCODE44}

