#!/bin/sh

datadir="/media/sf_MRI-Data/Projects"

project=${1}
vnum=${2}
hum_num=${3}

datadir=${datadir}/${project}/${vnum}/${hum_num}
bids=${vnum}_${hum_num}
echo ${datadir}

if [ -f ${datadir}/seg/${bids}-tfl.nii.gz ];then
	echo "seg/tfl file found"
fi
if [ -f ${datadir}/seg/*${bids}-tse.nii.gz ];then
	echo "seg/tse file found"
fi
${FSLDIR}/bin/bet  ${datadir}/seg/${bids}-tfl.nii.gz ${datadir}/seg/${bids}-tfl_brain
echo brain extraction done
${FSLDIR}/bin/flirt -dof 6 -searchcost mutualinfo -nosearch  -in ${datadir}/seg/${bids}-tfl_brain -ref ./etc/mni-derived/MNI2SW_T1_1mm_brain -out  ${datadir}/acpc/${bids}-tfl_brain  -omat ${datadir}/acpc/${bids}-tfl_brain.mat
echo Registred to MNI
${FSLDIR}/bin/flirt -applyxfm  -init ${datadir}/acpc/${bids}-tfl_brain.mat  -in ${datadir}/seg/${bids}-tfl.nii.gz  -ref ./etc/mni-derived/MNI2SW_T1_1mm_brain  -out ${datadir}/acpc/${bids}-tfl
echo Done TurboFLASH
echo --------------------------------------------------------------
echo "Co-registering TSE to TurboFlash"
${FSLDIR}/bin/bet  ${datadir}/seg/${bids}-tse ${datadir}/seg/${bids}-tse_brain -f 0.4
echo brain extraction done
# do bet on TFL again on standard for better performance
${FSLDIR}/bin/bet  ${datadir}/acpc/${bids}-tfl ${datadir}/acpc/${bids}-tfl_brain

${FSLDIR}/bin/flirt -dof 6 -searchcost mutualinfo -nosearch  -in ${datadir}/seg/${bids}-tse_brain  -ref ${datadir}/acpc/${bids}-tfl_brain  -out  ${datadir}/acpc/${bids}-tse_brain   -omat ${datadir}/acpc/${bids}-tse_brain.mat
echo Registred to MNI
${FSLDIR}/bin/flirt -applyxfm -init ${datadir}/acpc/${bids}-tse_brain.mat  -in ${datadir}/seg/${bids}-tse  -ref ${datadir}/acpc/${bids}-tfl_brain  -out  ${datadir}/acpc/${bids}-tse
echo Done TSE