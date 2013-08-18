#!/bin/bash

DOXY="/Applications/Doxygen.app/Contents/Resources/doxygen"

#run doxygen on all configs
for configs in doxygen*.config
do
	echo $configs
	$DOXY $configs
done
