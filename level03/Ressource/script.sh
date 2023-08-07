#!/bin/bash

const=322424845
sub=0

while [[ $sub -le 21 ]]
do
	nbr=$((const-sub))
	echo
	echo -----
	echo trying with $nbr
	cat <(echo $nbr) - | ./level03 
	((sub++))
done