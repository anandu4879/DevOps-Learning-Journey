#!/bin/bash

read -p "Enter first number: " num1
read -p "Enter second number: " num2
read -p "Enter operation (add, sub, mult,div): " operation

case $operation in
    add)
        result=$((num1 + num2))
        echo "Result: $result"
        ;;
    
    sub)
        result=$((num1 - num2))
        echo "Result: $result"
        ;;
    
    mult)
        result=$((num1 * num2))
        echo "Result: $result"
        ;;
    
    div)
        if [ "$num2" -eq 0 ]; then
            echo "Error: Cannot divide by zero"
        else
            result=$((num1 / num2))
            echo "Result: $result"
        fi
        ;;
    
    *)
        echo "Invalid operation. Choose: add, sub, mult, or div."
        ;;
esac