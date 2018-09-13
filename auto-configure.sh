#!/bin/sh

SkynetRemoteRepo='https://github.com/cloudwu/skynet.git'

SkynetSelfRepo='git@f2095r1007.iask.in:/home/datadisk/gitrepo/skynet.git'
GitVersion=`git --version`
echo $GitVersion


ROOT_DIR=`pwd`

SkynetDir=${ROOT_DIR}"/skynet"

#echo $SkynetDir

if  [ ! -d $SkynetDir ]
then
	git clone $SkynetSelfRepo
fi

cd skynet

echo `pwd`

GitRemoteRepo=`git remote -v`
#echo $GitRemoteRepo >> ../repo.txt

# print remote repo url
echo off
git remote -v | awk '{print $2}'
echo on
Urls=`git remote -v | awk '{ print $2}'`
#echo $Urls
CheckUrlResult=`echo $Urls | grep $SkynetRemoteRepo`
if [[ $CheckUrlResult != "" ]]; then
	echo "have add remote repo"
	exit
fi

echo "begin add remote repo"

git remote add skynet-remote $SkynetRemoteRepo

echo "config sucess,congratulations"

cd ..
