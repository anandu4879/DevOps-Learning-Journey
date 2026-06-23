#!/bin/bash

read -p "Enter a Word : " word

length=${#word}
uppercase=$(echo "$word" | tr '[:lower:]' '[:upper:]')
reverse=$(echo "$word" | rev)

echo "Length of the word is : $length"
echo "Uppercase of the word is : $uppercase"
echo "Reverse of the word is : $reverse"