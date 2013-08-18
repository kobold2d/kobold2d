#!/bin/bash

sourceDir=$1
targetDir=~/Library/Developer/Shared/Documentation/DocSets

echo Copying docsets to $targetDir ...
mkdir -p $targetDir

#run make all on all doxygen subfolders to create the docsets
#docsets are moved to the base folder to make installing them on the user's system simpler
for docset in $(ls -d ${sourceDir}com.kobold2d.*.docset/)
do
	docset=${docset:0:${#docset} - 1}
	echo Copying: $docset
	
	if [ -f $targetDir/$docset ];
	then
		rm -d -R $targetDir/$docset
	fi
	
	cp -R $docset $targetDir
	
	# This is only needed if Xcode is already open. Otherwise it will read in the docset the next time Xcode starts!
	
   	#  Construct a temporary applescript file to tell Xcode to load a docset.
	#rm -f loadDocSet.scpt
	#echo "tell application \"Xcode\"" >> loadDocSet.scpt
	#echo "load documentation set with path \"/Users/$USER/Library/Developer/Shared/Documentation/DocSets/$docset\"" >> loadDocSet.scpt
	#echo "end tell" >> loadDocSet.scpt
	#osascript loadDocSet.scpt
done

echo ''
echo To access Kobold2D help, choose:
echo '    "Xcode -> Xcode Help" followed by'
echo '    "Editor -> Explore Documentation"'
echo You must restart Xcode if it is currently running!
echo ''
