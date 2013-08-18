#!/bin/sh

# check for $SYMROOT ending in "/__Kobold2D__/build" which gives away the "Locations Specified by Targets" setting

case $SYMROOT in
     *"/__Kobold2D__/build");;
     *) exit 0;;
esac

echo
echo
echo " "
echo ===============================================
echo ===============================================
echo " "
echo BUILD LOCATIONS ISSUE --- YOU MUST READ THIS!!!
echo " "
echo "'Locations Specified by Targets' / 'Legacy' Build Location is enabled in Xcode -> Preferences -> Locations -> Advanced"
echo "This URL with available solutions will automatically open in your browser until the issue has been resolved:"
echo "http://www.kobold2d.com/x/6QAi"
echo " "
echo "====>> THE QUICK FIX <<===="
echo "1) open 'Common-All.xcconfig' in the Kobold2D-Libraries project (in BuildSettings group at the top)."
echo "2) uncomment the line: //SYMROOT = ~/Kobold2D/build"
echo " "
echo "Not recommended for continued use. This can lead to linker errors or even inexplicable crashes when working with different Kobold2D versions, unless you execute Product -> Clean every time you switch projects. Read the URL for more information."
echo " "
echo ===============================================
echo ===============================================
echo " "

open http://www.kobold2d.com/x/6QAi

exit 255
