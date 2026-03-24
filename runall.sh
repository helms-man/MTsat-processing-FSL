#!/bin/sh

datadir="/media/sf_Projects"
datadir="/media/sf_MRI-Data/Projects"

project=${1}
vnum=${2}
hum_num=${3}

datadir=${datadir}/${project}/${vnum}/${hum_num}
bids=${vnum}_${hum_num}
echo ${datadir}
echo --------------------------------------------------------------------------------------------------------------------
echo running 1_seg_acpc.sh
echo --------------------------------------------------------------------------------------------------------------------
./1_seg_acpc.sh ${project} ${vnum} ${hum_num}

echo --------------------------------------------------------------------------------------------------------------------
echo running 2_mt_acpc.sh
echo --------------------------------------------------------------------------------------------------------------------
./2_mt_acpc.sh ${project} ${vnum} ${hum_num}

echo --------------------------------------------------------------------------------------------------------------------
echo running 3_bias_acpc.sh
echo --------------------------------------------------------------------------------------------------------------------
./3_bias_acpc.sh ${project} ${vnum} ${hum_num}
echo **********************************************************
echo "Cleaning up"   #check exist avoids error messages
#/bin/rm ${datadir}/acpc/${bids}_A.nii.gz 
#/bin/rm ${datadir}/acpc/${bids}_bias.nii.gz 
#/bin/rm ${datadir}/acpc/${bids}_R1.nii.gz 
#/bin/rm ${datadir}/acpc/${bids}_R1corr.nii.gz 
/bin/rm ${datadir}/acpc/${bids}*mt* 
/bin/rm ${datadir}/acpc/${bids}*t1*
/bin/rm ${datadir}/acpc/${bids}*pd*
/bin/rm ${datadir}/acpc/${bids}*tst*