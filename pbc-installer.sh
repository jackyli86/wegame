#!/bin/bash

## install protobuf
yum install protobuf-c-compiler.x86_64 protobuf-compiler.x86_64 
if [ $? != 0 ]
then
    apt-get install protobuf-c-compiler.x86_64 protobuf-compiler.x86_64 
fi

echo 'protobuf version:'
protoc --version

if [ ! -d pbc ]
then
    echo 'begin clone pbc.git ...'
    git clone https://github.com/cloudwu/pbc.git
    echo 'finish clone pbc.git!!!'
fi


rootdir=${pwd}
protobuf_lua_path="${rootdir}/lib"
protobuf_so_path="${rootdir}/luaclib"

# 转义 / 为 sed 默认分隔符 ,这里不处理会出错
oldcontent="\/usr\/local\/include"
newcontent="\/data\/work\/wegame\/skynet\/3rd\/lua" #${lua53dir}


# make pbc static lib
cd pbc  
make
if [ $? != 0 ]
then
	exit('make pbc static lib failed')
fi


# modify lua path & make protobuf.so
cd binding/lua53
sed -i "s/${oldcontent}/${newcontent}/g" Makefile
make
if [ $? != 0 ]
then
	exit('make protobuf.so failed')
fi


# copy protobuf.lua&protobuf.so
echo "begin  copy protobuf.lua&protobuf.so ..."
cp -f protobuf.lua ${protobuf_lua_path}
cp -f protobuf.so ${protobuf_so_path}
echo "finish copy protobuf.lua&protobuf.so !!!"


cd ../../../
rm -Rf pbc


echo "\n"
echo "****************************"
echo "******configure ok !!!******"
echo "****************************"


