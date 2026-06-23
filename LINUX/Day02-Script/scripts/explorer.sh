#!/bin/bash

read -p"Enter the file path to search " path

if [ -d $path ]; then
    echo "The folder exists"
    echo "The contents of the folder are :"
    ls -l $path
elif [ -f $path ]; then
    echo "The file exists"
else
    echo "The file or folder does not exist"
fi