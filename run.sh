#!/bin/bash

PWD=`pwd`
#test

docker run -d -p 80:3838 \
    -v ${PWD}/shinyapp/:/srv/shiny-server/tak \
    -v ${PWD}/shinylog/:/var/log/shiny-server/tak \
    rocker/shiny
