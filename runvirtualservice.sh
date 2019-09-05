#!/bin/bash

#
#  Start the virtual Service
#

LOOPS=100000

echo "Working Directory is " $WORKDIR 

cd $WORKDIR
mkdir runfrom

while [ $LOOPS -gt 0 ]
do
  export DISPLAY=
  /IntegrationTester/RunTests -project $WORKDIR/Project/stockquotestub.ghp \
    -data $WORKDIR/runfrom -configuration $WORKDIR/runfrom -environment ubuntu -noHTTP \
    -run 3293aa9f:167a43a6e8e:-7c32 -environmentTags env
  sleep 10
done
