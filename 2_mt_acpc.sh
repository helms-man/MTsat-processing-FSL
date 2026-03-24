#!/bin/sh

datadir="/media/sf_MRI-Data/Projects"

project=${1}
vnum=${2}
hum_num=${3}

datadir=${datadir}/${project}/${vnum}/${hum_num}
bids=${vnum}_${hum_num}
echo ${datadir}

if [ -f ${datadir}/acpc/${bids}-tfl.nii.gz ];then
	echo "acpc/tfl file found"
fi
if [ -f ${datadir}/mt/${bids}-t1.nii.gz ];then
	echo "mt/t1.nii file found"
fi
if [ -f ${datadir}/mt/${bids}-pd.nii.gz ];then
	echo "mt/pd.nii file found"
fi
if [ -f ${datadir}/mt/${bids}-mt.nii.gz ];then
	echo "mt/mt.nii file found"
fi
echo Doing BET
${FSLDIR}/bin/bet ${datadir}/mt/${bids}-t1 ${datadir}/mt/${bids}-t1_brain
${FSLDIR}/bin/bet ${datadir}/mt/${bids}-pd ${datadir}/mt/${bids}-pd_brain
${FSLDIR}/bin/bet ${datadir}/mt/${bids}-mt ${datadir}/mt/${bids}-mt_brain
echo converting images to float
fslmaths ${datadir}/mt/${bids}-t1 -add 0.0 ${datadir}/mt/${bids}-t1_float -odt float
fslmaths ${datadir}/mt/${bids}-pd -add 0.0 ${datadir}/mt/${bids}-pd_float -odt float
fslmaths ${datadir}/mt/${bids}-mt -add 0.0 ${datadir}/mt/${bids}-mt_float -odt float
echo Registering T1-w
${FSLDIR}/bin/flirt -dof 6 -searchcost mutualinfo -nosearch  \
-in ${datadir}/mt/${bids}-t1_brain  \
-ref ${datadir}/acpc/${bids}-tfl_brain \
-out ${datadir}/acpc/${bids}-t1_brain  \
-omat ${datadir}/acpc/${bids}-t1_brain.mat

${FSLDIR}/bin/flirt -applyxfm  -init ${datadir}/acpc/${bids}-t1_brain.mat  \
-in ${datadir}/mt/${bids}-t1_float  \
-ref ${datadir}/acpc/${bids}-tfl_brain  \
-out ${datadir}/acpc/${bids}-t1

echo Registering PD-w
${FSLDIR}/bin/flirt -dof 6 -searchcost mutualinfo -nosearch  \
-in ${datadir}/mt/${bids}-pd_brain  -ref ${datadir}/acpc/${bids}-tfl_brain \
-out ${datadir}/acpc/${bids}-pd_brain  \
-omat ${datadir}/acpc/${bids}-pd_brain.mat

${FSLDIR}/bin/flirt -applyxfm  -init ${datadir}/acpc/${bids}-pd_brain.mat  \
-in ${datadir}/mt/${bids}-pd_float  \
-ref ${datadir}/acpc/${bids}-tfl_brain  \
-out ${datadir}/acpc/${bids}-pd

echo Registering MT-w
${FSLDIR}/bin/flirt -dof 6 -searchcost mutualinfo -nosearch  -in ${datadir}/mt/${bids}-mt_brain  -ref ${datadir}/acpc/${bids}-tfl_brain -out ${datadir}/acpc/${bids}-mt_brain  -omat ${datadir}/acpc/${bids}-mt_brain.mat

${FSLDIR}/bin/flirt -applyxfm  -init ${datadir}/acpc/${bids}-mt_brain.mat  -in ${datadir}/mt/${bids}-mt_float  -ref ${datadir}/acpc/${bids}-tfl_brain  -out ${datadir}/acpc/${bids}-mt

echo Masking
${FSLDIR}/bin/bet ${datadir}/acpc/${bids}-pd ${datadir}/acpc/${bids}-pd-msk -f 0.45

fslmaths  ${datadir}/acpc/${bids}-pd-msk -bin -ero  ${datadir}/acpc/${bids}-mask

fslmaths  ${datadir}/acpc/${bids}-pd  -mul ${datadir}/acpc/${bids}-mask  ${datadir}/acpc/${bids}-pd-msk

fslmaths  ${datadir}/acpc/${bids}-t1  -mul ${datadir}/acpc/${bids}-mask  ${datadir}/acpc/${bids}-t1-msk

fslmaths  ${datadir}/acpc/${bids}-mt  -mul ${datadir}/acpc/${bids}-mask  ${datadir}/acpc/${bids}-mt-msk


echo Doing arithmetics
# TODO change to fslmaths

fslmaths ${datadir}/acpc/${bids}-pd-msk -div 0.0872664 ${datadir}/acpc/${bids}-pd_d

fslmaths ${datadir}/acpc/${bids}-t1-msk -div 0.2617993 ${datadir}/acpc/${bids}-t1_d

fslmaths ${datadir}/acpc/${bids}-pd_d -sub ${datadir}/acpc/${bids}-t1_d ${datadir}/acpc/${bids}-pd-t1_d

echo "Done divisions"

fslmaths ${datadir}/acpc/${bids}-pd-msk -mul 0.0872664 -div 0.05042 ${datadir}/acpc/${bids}-pd_m

fslmaths ${datadir}/acpc/${bids}-t1-msk -mul 0.2617993 -div 0.0223 ${datadir}/acpc/${bids}-t1_m

fslmaths ${datadir}/acpc/${bids}-t1_m -sub ${datadir}/acpc/${bids}-pd_m ${datadir}/acpc/${bids}-t1-pd_m

echo "Done multiplications" 

fslmaths ${datadir}/acpc/${bids}-t1-pd_m -div ${datadir}/acpc/${bids}-pd-t1_d ${datadir}/acpc/${bids}_R1

fslmaths ${datadir}/acpc/${bids}_R1 -thr 0 -uthr 9.999 ${datadir}/acpc/${bids}_R1

echo "Done thresholded R1 map [0 10] in 1/s"

fslmaths ${datadir}/acpc/${bids}-pd-t1_d -mul 1000 -div ${datadir}/acpc/${bids}-t1-pd_m ${datadir}/acpc/${bids}_T1

fslmaths ${datadir}/acpc/${bids}_T1 -div 22.3 -mul 0.2617994 -add 3.81972 -mul ${datadir}/acpc/${bids}-t1-msk ${datadir}/acpc/${bids}_A

fslmaths ${datadir}/acpc/${bids}_A -mul 0.0872664 -sub ${datadir}/acpc/${bids}-mt-msk -div ${datadir}/acpc/${bids}-mt-msk -mul ${datadir}/acpc/${bids}_R1 -mul 2.521 -sub 0.380771  ${datadir}/acpc/${bids}_MT

fslmaths ${datadir}/acpc/${bids}_MT -thr -0.4 -uthr 9.999 ${datadir}/acpc/${bids}_MT
echo "Done thresholded MT map from A and R1 [-0.4 10] in p.u. with neg. offset"

fslmaths ${datadir}/acpc/${bids}_T1 -thr 0 -uthr 9999.9 ${datadir}/acpc/${bids}_T1
echo "Done thresholded T1 map [0 10000] in ms"

fslmaths ${datadir}/acpc/${bids}_A -thr 0 -uthr 100000 ${datadir}/acpc/${bids}_A
echo "Done thresholded A map [0 100000] in a.u."


fslmaths ${datadir}/acpc/${bids}-mt-msk -div ${datadir}/acpc/${bids}-pd-msk -sub 1 -mul -100 ${datadir}/acpc/${bids}_MTR

fslmaths ${datadir}/acpc/${bids}_MTR -thr -100.1 -uthr 100 ${datadir}/acpc/${bids}_MTR

echo "Done offseted MTR map [-100 100] in p.u."


echo ""

echo "Cleaning up"   #check exist avoids error messages
/bin/rm ${datadir}/mt/${bids}*_brain.nii.gz 
/bin/rm ${datadir}/mt/${bids}*_float.nii.gz 
#/bin/rm ${datadir}/acpc/${bids}*_brain.nii.gz 
/bin/rm ${datadir}/acpc/${bids}*msk.nii.gz 
/bin/rm ${datadir}/acpc/${bids}*_m.nii.gz
/bin/rm ${datadir}/acpc/${bids}*_d.nii.gz

echo "Setting permissions for MRIcro uncompression..."
echo ""
chmod 775 ${datadir}/acpc/${bids}*.nii.gz

echo "MT mapping done - now check results"
$FSLDIR/bin/fsleyes &


