#!/bin/bash

#NION=$(grep NEDOS OUTCAR | awk '{print $12}')
#NEDOS=$(grep NEDOS OUTCAR | awk '{print $6}')
#echo "NION= " $NION
#echo "NEDOS= " $NEDOS

echo " ONLY FOR NON-COLLINEAR CALCULATION"
echo "I need 1.INCAR   2.POSCAR   3.OUTCAR(with correct E-fermi)   4.DOSCAR"

e_fermi=$(grep -m1 E-fer OUTCAR | awk '{print $3}')
#NEDOS=$(grep NEDOS INCAR | awk '{print $3}')
NEDOS=$(grep NEDOS OUTCAR | awk '{print $6}')
lines=$(($NEDOS+6))
no_of_orbital=$(awk -v p="$(($NEDOS+15))" 'NR==p {print $0}' DOSCAR | awk 'END {print NF}')
no_of_species=$(awk ' {if ( NR == 6 )  print NF }' POSCAR)        # To find the type and total no. of species or elements    
echo "The no. of species is : "$no_of_species

NION=0
for (( i=1; i<=$no_of_species; i++ ))
      do
      spec[$i]=$(awk -v j="$i" '{ if ( NR == 6 ) print $j }' POSCAR)
      tot_atm_spec[$i]=$(awk -v j="$i" '{ if ( NR == 7 ) print $j }' POSCAR)
      echo "Species $i : " ${spec[$i]} ${tot_atm_spec[$i]}
      NION=$(($NION+${tot_atm_spec[$i]}))

      done

echo "NION= " $NION
echo "NEDOS= " $NEDOS
echo "No. of orbitals =  "  $((($no_of_orbital-1)/2))
echo "Fermi Energy $e_fermi eV"
echo "Lines " $lines

# For total DOS
head -$lines DOSCAR |tail -$NEDOS > doss.dat
awk -v e="$e_fermi" '{ $1=$1-e;printf "%12.7f %12.7f \n", $1, $2;}' doss.dat > TDOS.dat
#awk -v e="$e_fermi" '{ $1=$1-e;printf "%12.7f %12.7f \n", $1, $3;}' doss.dat > TDOS_DW.dat
rm doss.dat --verbose

n=0

if [ $no_of_orbital == 37 ]
then
for (( i=1; i<=$no_of_species; i++  ))
do   
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0}' TDOS.dat > spec_${spec[$i]}
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0}' TDOS.dat > spec_${spec[$i]}_mx
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0}' TDOS.dat > spec_${spec[$i]}_my
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0}' TDOS.dat > spec_${spec[$i]}_mz

     for((j=1; j<=${tot_atm_spec[$i]}; j++))
     do
     n=$(($n+1))
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $2, $6, $10, $14, $18, $22, $26, $30, $34}' DOSCAR > temp             
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $3, $7, $11, $15, $19, $23, $27, $31, $35}' DOSCAR > tempx
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $4, $8, $12, $16, $20, $24, $28, $32, $36}' DOSCAR > tempy
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $5, $9, $13, $17, $21, $25, $29, $33, $37}' DOSCAR > tempz
#    awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $3, $5, $7, $9, $11, $13, $15, $17, $19}' DOSCAR > temp_DW

     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10 }' TDOS.dat temp > atom_${spec[$i]}_${j}  # concatenate side by side 1st column of TDOS_UP.dat and 2..10 column of temp_UP
     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10 }' TDOS.dat tempx > atom_${spec[$i]}_${j}_mx
     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10 }' TDOS.dat tempy > atom_${spec[$i]}_${j}_my
     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10 }' TDOS.dat tempz > atom_${spec[$i]}_${j}_mz
#    awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10 }' TDOS_UP.dat temp_DW > atom_${spec[$i]}_${j}_DW

     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10} 
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10}' temp spec_${spec[$i]} > tspec_${spec[$i]}   
     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10} 
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10}' tempx spec_${spec[$i]}_mx > tspecx_${spec[$i]}
     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10} 
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10}' tempy spec_${spec[$i]}_my > tspecy_${spec[$i]}
     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10}
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10}' tempz spec_${spec[$i]}_mz > tspecz_${spec[$i]}
#    awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10} 
#NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10}' temp_DW spec_${spec[$i]}_DW  > spec_${spec[$i]}

     cp tspec_${spec[$i]} spec_${spec[$i]}
     cp tspecx_${spec[$i]} spec_${spec[$i]}_mx
     cp tspecy_${spec[$i]} spec_${spec[$i]}_my
     cp tspecz_${spec[$i]} spec_${spec[$i]}_mz
#    cp spec_${spec[$i]} spec_${spec[$i]}_DW
   
     rm tspec_${spec[$i]} temp
     rm tspecx_${spec[$i]} tempx
     rm tspecy_${spec[$i]} tempy
     rm tspecz_${spec[$i]} tempz
#    rm spec_${spec[$i]} temp_DW

     done

#awk '{print $1, $2, $3+$4+$5, $6+$7+$8+$9+$10}' spec_${spec[$i]}_UP > spec_${spec[$i]}_UP_l
#awk '{print $1, $2, $3+$4+$5, $6+$7+$8+$9+$10}' spec_${spec[$i]}_DW > spec_${spec[$i]}_DW_l

done 




elif [ $no_of_orbital == 65 ]
then     
for (( i=1; i<=$no_of_species; i++  ))
do
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0,$11*0.0,$12*0.0,$13*0.0,$14*0.0,$15*0.0,$16*0.0,$17*0.0}' TDOS.dat > spec_${spec[$i]}
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0,$11*0.0,$12*0.0,$13*0.0,$14*0.0,$15*0.0,$16*0.0,$17*0.0}' TDOS.dat > spec_${spec[$i]}_mx
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0,$11*0.0,$12*0.0,$13*0.0,$14*0.0,$15*0.0,$16*0.0,$17*0.0}' TDOS.dat > spec_${spec[$i]}_my
     awk '{print $1,$2*0.0,$3*0.0,$4*0.0,$5*0.0,$6*0.0,$7*0.0,$8*0.0,$9*0.0,$10*0.0,$11*0.0,$12*0.0,$13*0.0,$14*0.0,$15*0.0,$16*0.0,$17*0.0}' TDOS.dat > spec_${spec[$i]}_mz

     for((j=1; j<=${tot_atm_spec[$i]}; j++))
     do
     n=$(($n+1))
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $2, $6, $10, $14, $18, $22, $26, $30, $34, $38, $42, $46, $50, $54, $58, $62}' DOSCAR > temp          
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $3, $7, $11, $15, $19, $23, $27, $31, $35, $39, $43, $47, $51, $55, $59, $63}' DOSCAR > tempx
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $4, $8, $12, $16, $20, $24, $28, $32, $36, $40, $44, $48, $52, $56, $60, $64}' DOSCAR > tempy
     awk -v k="$((($NEDOS*$n)+7))" -v l="$((($NEDOS*$(($n+1)))+6))" -v m="$n" 'NR==k+m , NR==l+m  {print $1, $5, $9, $13, $17, $21, $25, $29, $33, $37, $41, $45, $49, $53, $57, $61, $65}' DOSCAR > tempz

     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' TDOS.dat temp > atom_${spec[$i]}_${j}  # concatenate side by side 1st column of TDOS_UP.dat and 2..10 column of temp_UP
     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' TDOS.dat tempx > atom_${spec[$i]}_${j}_mx
     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' TDOS.dat tempy > atom_${spec[$i]}_${j}_my
     awk 'NR==FNR{s[FNR]=$1} NR!=FNR{print s[FNR],$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' TDOS.dat tempz > atom_${spec[$i]}_${j}_mz

     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10;f1[FNR]=$11;f2[FNR]=$12;f3[FNR]=$13;f4[FNR]=$14;f5[FNR]=$15;f6[FNR]=$16;f7[FNR]=$17} 
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10,
f1[FNR]=f1[FNR]+$11,f2[FNR]=f2[FNR]+$12,f3[FNR]=f3[FNR]+$13,f4[FNR]=f4[FNR]+$14,f5[FNR]=f5[FNR]+$15,f6[FNR]=f6[FNR]+$16,f7[FNR]=f7[FNR]+$17}' temp spec_${spec[$i]}  > tspec_${spec[$i]}
     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10;f1[FNR]=$11;f2[FNR]=$12;f3[FNR]=$13;f4[FNR]=$14;f5[FNR]=$15;f6[FNR]=$16;f7[FNR]=$17} 
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10,
f1[FNR]=f1[FNR]+$11,f2[FNR]=f2[FNR]+$12,f3[FNR]=f3[FNR]+$13,f4[FNR]=f4[FNR]+$14,f5[FNR]=f5[FNR]+$15,f6[FNR]=f6[FNR]+$16,f7[FNR]=f7[FNR]+$17}' tempx spec_${spec[$i]}_mx  > tspecx_${spec[$i]}
     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10;f1[FNR]=$11;f2[FNR]=$12;f3[FNR]=$13;f4[FNR]=$14;f5[FNR]=$15;f6[FNR]=$16;f7[FNR]=$17} 
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10,
f1[FNR]=f1[FNR]+$11,f2[FNR]=f2[FNR]+$12,f3[FNR]=f3[FNR]+$13,f4[FNR]=f4[FNR]+$14,f5[FNR]=f5[FNR]+$15,f6[FNR]=f6[FNR]+$16,f7[FNR]=f7[FNR]+$17}' tempy spec_${spec[$i]}_my  > tspecy_${spec[$i]}
     awk 'NR==FNR{s[FNR]=$2;p1[FNR]=$3;p2[FNR]=$4;p3[FNR]=$5;d1[FNR]=$6;d2[FNR]=$7;d3[FNR]=$8;d4[FNR]=$9;d5[FNR]=$10;f1[FNR]=$11;f2[FNR]=$12;f3[FNR]=$13;f4[FNR]=$14;f5[FNR]=$15;f6[FNR]=$16;f7[FNR]=$17} 
NR!=FNR{print $1,s[FNR]=s[FNR]+$2,p1[FNR]=p1[FNR]+$3,p2[FNR]=p2[FNR]+$4,p3[FNR]=p3[FNR]+$5,d1[FNR]=d1[FNR]+$6,d2[FNR]=d2[FNR]+$7,d3[FNR]=d3[FNR]+$8,d4[FNR]=d4[FNR]+$9,d5[FNR]=d5[FNR]+$10,
f1[FNR]=f1[FNR]+$11,f2[FNR]=f2[FNR]+$12,f3[FNR]=f3[FNR]+$13,f4[FNR]=f4[FNR]+$14,f5[FNR]=f5[FNR]+$15,f6[FNR]=f6[FNR]+$16,f7[FNR]=f7[FNR]+$17}' tempz spec_${spec[$i]}_mz  > tspecz_${spec[$i]}


cp tspec_${spec[$i]} spec_${spec[$i]}
cp tspecx_${spec[$i]} spec_${spec[$i]}_mx
cp tspecy_${spec[$i]} spec_${spec[$i]}_my
cp tspecz_${spec[$i]} spec_${spec[$i]}_mz

     rm tspec_${spec[$i]} temp
     rm tspecx_${spec[$i]} tempx
     rm tspecy_${spec[$i]} tempy
     rm tspecz_${spec[$i]} tempz
     done


done 







else
echo    "Too less or too high no. of orbitals"
fi

