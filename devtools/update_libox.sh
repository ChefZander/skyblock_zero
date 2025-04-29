#!/bin/bash

# so, libox is in ./../mods/libox

rm -rf ./../mods/libox
git clone https://github.com/theet1234/libox
mv libox ./../mods/
rm -rf ./../mods/libox/.git

# yipee i know shell scripting, i can type rm -rf a bunch of type xD
# if you are afraid to run this script, you are allowed to be xD
