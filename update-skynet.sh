#!/bin/bash

pwd

# 0 enter source dir
cd skynet/

# 1 update origin branch
git pull

# 2 fetch skynet-remote master branch
git fetch skynet-remote HEAD:tmp

# 3 show two branches difference
git diff tmp

# 4 merge tmp branch to origin branch
git merge tmp

# 5 delete tmp branch
git branch -D tmp

# 6 enter root dir
cd ..

echo "****************************"
echo "******configure ok !!!******"
echo "****************************"
