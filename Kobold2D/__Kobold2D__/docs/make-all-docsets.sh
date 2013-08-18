#!/bin/bash

rm -rf *.docset/

#run make all on all doxygen subfolders to create the docsets
#docsets are moved to the base folder to make installing them on the user's system simpler
for folder in $(ls -d */)
do
	folder="$folder""html";
   	if [ -d $folder ]; 
   	then
   		echo $folder;
    	cd $folder;
  	 	make all;
  	 	make install;
   	mv *.docset ../../;
   	rm -f Tokens.xml
   	rm -f Nodes.xml	
     	cd ../../;
   	fi;
done
