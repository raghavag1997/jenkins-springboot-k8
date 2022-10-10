#!/bin/bash


#Getting Image Name from Environment Variables
echo $imageName

#If exit code ==1 which means high vul
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.32.1 image -q  --severity CRITICAL  --exit-code 1 $imageName


status_code=$?
echo $status_code

if [ $status_code -eq 1 ];
then
        echo "CRITICAL VUL FOUND"
else
        echo "NO CRITICAL VUL FOUND"
fi
