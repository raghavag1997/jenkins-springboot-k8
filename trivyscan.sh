#!/bin/bash

#NR represent link no 

dockerImage=$(awk 'NR==1 {print $2}' Dockerfile)

echo $dockerImage

#If exit code ==1 which means critical vul

sudo docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.32.1 image -q --vuln-type os --severity CRITICAL  --exit-code 1 $dockerImage

#If exit code ==1 which means high or medium vul

sudo docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.32.1 image -q --vuln-type os --severity HIGH,MEDIUM  --exit-code 0 $dockerImage

status_code=$?
echo $status_code

if [ $status_code -eq 1 ];
then
        echo "CRITICAL VUL FOUND"
else
        echo "NO CRITICAL VUL FOUND"
fi
