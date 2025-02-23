#!/bin/bash
# salva i valori relativi alla transizione e alla separazione per un determinato profilo ai valori Ncrit selezionati.
# Viene verificato nel range di Reynold (10^6 < Re < 10^8) e nel range di alpha (-8 < alpha < 8)
#

INPUT='inputTransizione'
read  -p "inserire percorso file dat del profilo: " PROFILO
read  -p "inserire nome profilo: " NOME
read  -p "inserire paramentro  pannellizzazione p (visionare file consigli_p.txt):" pval
read  -p "inserire valore Ncrit: " Ncrit

mkdir -p ./dati/transizione_$NOME

for Re in $(seq 6 1 8); do
  echo "LOAD $PROFILO" > $INPUT
  echo "PPAR" >> $INPUT
  echo "N 364" >> $INPUT 
  echo "P $pval"  >> $INPUT 
  echo '  ' >> $INPUT
  echo '  ' >> $INPUT
  echo '  ' >> $INPUT
  echo "OPER" >> $INPUT 
  echo "visc" >> $INPUT 
  echo "1e$Re" >> $INPUT 
  echo "vpar" >> $INPUT
  echo "N $Ncrit" >> $INPUT
  echo '  ' >> $INPUT
  echo "iter 500" >> $INPUT
  echo "pacc" >> $INPUT 
  echo "./dati/transizione_"$NOME"/pol_Re_$Re.dat" >> $INPUT
  echo '  ' >> $INPUT
  for A in $(seq -8 0.5 8); do
	echo "a $A" >> $INPUT
  	echo "vplo" >> $INPUT
	echo "cf" >> $INPUT
	echo "dump" >> $INPUT
	echo "./dati/transizione_"$NOME"/cf_Re_"$Re"_a"$A".dat"  >> $INPUT
	echo '  ' >> $INPUT
  done
  echo "pacc"
  echo '  '   >> $INPUT
  echo '  '   >> $INPUT
  echo "quit"  >> $INPUT
	  xfoil < $INPUT
done

