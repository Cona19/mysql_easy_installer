TEST=t2
for i in random sparse hot
#for i in sparse
do
    echo ${i}
    echo "/basic.sh 100 ${TEST}"
    ./basic.sh 100 ${TEST} ${i}
    ./flush.sh 100 ${TEST} ${i}
    ./no_flush.sh 100 ${TEST} ${i}
    echo "/basic.sh 25 ${TEST}"
    ./basic.sh 25 ${TEST} ${i}
    ./flush.sh 25 ${TEST} ${i}
    ./no_flush.sh 25 ${TEST} ${i}
done
