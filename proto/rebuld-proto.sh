#!/bin/bash


filelist=`ls -l | awk '{ print $9 }'`

echo $filelist

filenamesuffix='.proto'
generatefilesuffix='.pb'

for i in $filelist 
do
	if [ -f $i ] && [ ${#i} -gt 6 ]
	then
		namesuffix=${i:0-6}
		if [ $namesuffix != $filenamesuffix ]
		then
			continue
		fi
		
		#echo ${i:0-6}
		filenamelen=${#i}-6
		filename=${i:0:$filenamelen}
		#echo $i,$filename	
	    	sudo protoc --descriptor_set_out ${filename}${generatefilesuffix} $i
	fi
	#echo $i
done



