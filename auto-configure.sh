#!/bin/bash

# remote repo
SkynetRemoteRepo='https://github.com/cloudwu/skynet.git'
# SkynetSelfRepo='git@f2095r1007.iask.in:/home/datadisk/gitrepo/skynet.git'
SkynetSelfRepo='ssh://git@www.newbee.tech:10022/home/datadisk/gitrepo/skynet.git'

# git version
git --version


# check skynet is exist
SkynetDir=$(pwd)/skynet
if  [ ! -d $SkynetDir ]
then
	git clone $SkynetSelfRepo
fi

cd skynet

# remote repo has been added!
Urls=`git remote -v | awk 'BEGIN{url=""} { if(url==""&&$2=="https://github.com/cloudwu/skynet.git"){ url=$2} } END{ print url}'`
CheckUrlResult=`echo $Urls | grep $SkynetRemoteRepo`
if [[ $CheckUrlResult != "" ]]; then
	echo "have add skynet remote repo"
	exit
fi

# add remote repo
git remote add skynet-remote $SkynetRemoteRepo

# enter root dir
cd ..

echo "****************************"
echo "******configure ok !!!******"
echo "****************************"


