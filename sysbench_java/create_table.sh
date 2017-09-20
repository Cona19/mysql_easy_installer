#!/bin/sh

number=1
while [ $number -lt 1001 ]
do
    echo create table bench"$number" "(benchid int(10) not null primary key, benchhot int(4), benchdata varchar(32) );"
	number=`expr $number + 1`
done
