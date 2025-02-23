#!/bin/bash

#salva il cp calcolato da xfoil per il profilo dato in input per il range di angoli di incidenza richiesti

IFILE='instruction_xfoil.txt'
START=$1
END=$2
STEP=$3
CodiceProfilo=$4

NACA_LIST=("./dati/$4")
NACA_NAME=("$4")

for NACA_CASE in ${NACA_LIST[@]}
do 
    #for (( ALPHA = 1;  ALPHA <= 5 ; ALPHA +=0,1)) ; 
    for ALPHA in $(seq $1 $3 $2);
    do
        echo "LOAD $NACA_LIST" > $IFILE
        echo "OPER" >> $IFILE
        echo "ALFA $ALPHA" >> $IFILE
        echo "CPWR "$NACA_CASE"_"$ALPHA"_cp.txt" >> $IFILE
        echo '  ' >> $IFILE
        echo "QUIT" >> $IFILE
        xfoil < $IFILE
        #sleep 2 
    done
    echo ''
done 
