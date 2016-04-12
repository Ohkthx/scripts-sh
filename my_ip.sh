#!/bin/bash
source boxes.sh
ip=`wget http://ipinfo.io/ip -qO -`
box_draw ${ip}

