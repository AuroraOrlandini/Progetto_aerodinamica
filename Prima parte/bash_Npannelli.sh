#!/bin/bash
#estrae i vaolri di Cl Cm e Cp per angolo d'incidenza pari a 2 gradi considerando un profilo con il numero di pannelli indicati in input
IFILE='instruction_xfoil.txt'

CodiceProfilo=$1
Npannelli=$2

NACA_LIST=("0012")

for NACA_CASE in ${NACA_LIST[@]}
do 
        echo "NACA $NACA_CASE" > $IFILE
        echo "PPAR " >> $IFILE  		
        echo "N $2" >> $IFILE   		 
        echo '  ' >> $IFILE
        echo '  ' >> $IFILE
        echo '  ' >> $IFILE
        echo "save profilo_Npannelli.dat" >> $IFILE 
        echo "OPER" >> $IFILE
        echo "ALFA 2" >> $IFILE
        echo "CPWR NACA_"$NACA_CASE"_2_cp.txt" >> $IFILE
        echo "PACC" >> $IFILE
        echo "cl_cm.dat" >> $IFILE
        echo '  ' >> $IFILE
        echo "alfa 2" >> $IFILE
        echo '  ' >> $IFILE
        echo "QUIT" >> $IFILE
        xfoil < $IFILE
        sleep 2 
    echo ''
done 
