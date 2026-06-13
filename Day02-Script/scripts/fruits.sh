#!/bin/bash

fruits=("Apple" "Banana" "Cherry" "Kiwi" "Mango")
count=1;
for fruit in "${fruits[@]}"
 do
    echo ${count} : ${fruit}
    count=$((count+1))
 done


 total=${#fruits[@]}
    echo "Total number of fruits : $total"  

read -p "Enter the name of the fruit to search : " search

for frut in ${fruits[@]}
do 
    if [ $frut == $search ]; then
        echo "The fruit $search is found in the list"
        exit 0
    fi
done