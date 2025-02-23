#!/bin/bash
#questo script estrae dal file di polare salvato da Xfoil i valori di Cl e Cm
cat cl_cm.dat | sed -n '13p' | awk '{print $2,$5}' >> temp
echo "CL CM" > cl_cm.dat
cat temp >> cl_cm.dat
rm temp
mv cl_cm.dat clcm_NACA0012.dat
