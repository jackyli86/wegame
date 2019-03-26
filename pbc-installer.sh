#!/bin/bash

## install protobuf
yum install protobuf-c-compiler.x86_64 protobuf-compiler.x86_64 
if [ $? != 0 ]
then
    apt-get install protobuf-c-compiler protobuf-compiler 
fi

# protoc version
protoc --version

# if not exist , clone pbc
if [ ! -d pbc ]
then
    git clone https://github.com/cloudwu/pbc.git
fi

# some important path
rootdir=$(pwd)
protobuf_lua_path="${rootdir}/lib"
protobuf_so_path="${rootdir}/luaclib"

# modify makefile file with newcontent replace oldcontent
oldcontent="\/usr\/local\/include"
newcontent="${rootdir}/skynet/3rd/lua" 

oldcontent=${oldcontent////\/}
newcontent=${newcontent////\/}

# make pbc static lib
cd pbc  
make
if [ $? != 0 ]
then
	exit 1
fi

# modify lua path & make protobuf.so
cd binding/lua53
sed -i "s/${oldcontent}/${newcontent}/g" Makefile
make
if [ $? != 0 ]
then
	exit 2
fi


# copy protobuf.lua&protobuf.so
cp -f protobuf.lua ${protobuf_lua_path}
cp -f protobuf.so ${protobuf_so_path}
echo "finish copy protobuf.lua&protobuf.so !!!"

# enter root dir & remove pbc 
cd ../../../
rm -Rf pbc



echo "****************************"
echo "******configure ok !!!******"
echo "****************************"


