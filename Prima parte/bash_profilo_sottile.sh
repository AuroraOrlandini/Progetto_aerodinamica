#!/bin/bash
#salva il profilo con spessore molto sottile in modo che possa essere importato in matlab
IFILE='instruction_xfoil.txt'
CodiceProfilo=$1

NACA_LIST=("./dati/$1")
NACA_NAME=("$1")

for NACA_CASE in ${NACA_LIST[@]}
do 
    #for (( ALPHA = 1;  ALPHA <= 5 ; ALPHA +=0,1)) ; 
    #for ALPHA in $(seq $1 $3 $2);
    #do
        echo "LOAD $NACA_LIST" > $IFILE
	    echo "GDES" >> $IFILE
        echo "TSET" >> $IFILE
        echo "0.01" >> $IFILE
        echo '  ' >> $IFILE
        echo "exec" >> $IFILE
        echo '  ' >> $IFILE
        echo "PPAR " >> $IFILE
        echo "N 364" >> $IFILE
        echo '  ' >> $IFILE
        echo '  ' >> $IFILE
        echo '  ' >> $IFILE
        echo "SAVE "$NACA_CASE"_thin.dat" >> $IFILE
        echo "QUIT">> $IFILE
        xfoil < $IFILE
 	#sleep 2 
    #done
    echo ''
done 

