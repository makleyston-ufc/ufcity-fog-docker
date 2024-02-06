#!/bin/bash

echo "Stopping the execution of containers."
if [[ $(sudo docker ps -q) ]]; then
    sudo docker stop $(sudo docker ps -q)
else
    echo "No containers to stop."
fi

echo "Removing the containers."
if [[ $(sudo docker ps -a -q) ]]; then
    sudo docker rm $(sudo docker ps -a -q)
else
    echo "No containers to remove."
fi

echo "Removing container images."
if [[ $(sudo docker images -q) ]]; then
    sudo docker rmi $(sudo docker images -q)
else
    echo "No container images to remove."
fi

echo "Removing installation directories and files."
if [[ -e "./volume" ]]; then
    sudo rm -r ./volume
    echo "Directory './volume' removed."
else
    echo "Directory './volume' not found."
fi

if [[ -e "./dockerfiles" ]]; then
    sudo rm -r ./dockerfiles
    echo "Directory './dockerfiles' removed."
else
    echo "Directory './dockerfiles' not found."
fi

if [[ -e "./.version" ]]; then
    sudo rm -r ./.version
    echo "File './.version' removed."
else
    echo "File './.version' not found."
fi

echo "Finish."