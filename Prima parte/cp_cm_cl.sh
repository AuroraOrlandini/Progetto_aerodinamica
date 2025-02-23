#!/bin/bash
#salva il valore Cl, Cm e Cp per il file profilo NACA dato in input
ALPHA=$1
FOIL=$2 
N=$3 
echo "NACA" >input
echo "$FOIL">>input
echo 'PPAR'>>input
echo "N">>input
echo "$N">>input
echo '  ' >>input
echo '  '>>input
echo 'save'>>input
echo "NACA_"$FOIL"_"$N".dat">>input
echo "  " >>input
echo 'oper' >>input
echo "a $ALPHA" >>input
echo "cpwr cp_"$N"_"$FOIL".dat">>input
echo 'pacc' >>input
echo "clcm_"$N"_"$FOIL".dat">>input
echo '  ' >>input
echo "a "$ALPHA>>input
echo '  '>>input
echo 'quit' >>input

xfoil<input

sed -n '13p' "clcm_"$N"_"$FOIL".dat" | awk '{print $2,$5}' >> temp
echo "CL CM" > "clcm_"$N"_"$FOIL
cat temp >> "clcm_"$N"_"$FOIL
rm temp
mv "clcm_"$N"_"$FOIL "clcm_"$N"_"$FOIL".dat" 



