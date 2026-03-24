#!/bin/sh

datadir="/media/sf_MRI-Data/Projects"

project=${1}
vnum=${2}
hum_num=${3}

datadir=${datadir}/${project}/${vnum}/${hum_num}
bids=${vnum}_${hum_num}
echo ${datadir}

echo "Calculating transmit bias for TurboSTEAM sequence on TIM TRIO"
echo "Calibration by A.Lutti, WTCN, London: MRM submitted" 
echo ""
#  calibration as of march-09: p=1.094857, q=0.63147
p=1.094857         # a_max = p/q = 1.6764
echo "peak shift " $p
q=0.6531
echo "spread factor " $q
r=0.1987115        # r = p*p-1


echo Preprocessing
echo Average TSTEAM images and convert to float
echo OBS: in case of motion choose best volume and rename manually
echo ""

if [ -f ${datadir}/rf/${bids}-tst60.nii.gz ];then
    echo rf/tst-60.nii was found
    fslmaths  ${datadir}/rf/${bids}-tst60  -mul 1.0  ${datadir}/rf/${bids}-tst60 -odt float
fi

if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-tst60` -eq 0 ];then
    echo "Averaging 60 degree TSTEAM volumes"

    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-tst60-1` -eq 0 ];then
	echo "1st tst60 series does not exist or is not in a supported format"
	exit
    fi
    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-tst60-2` -eq 0 ];then
	echo "2nd tst60 series does not exist or is not in a supported format"
	exit
    fi

    fslmaths ${datadir}/rf/${bids}-tst60-1 -add ${datadir}/rf/${bids}-tst60-2 -div 2 ${datadir}/rf/${bids}-tst60 -odt float
fi


if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-tst100` -eq 1 ];then

    fslmaths  ${datadir}/rf/${bids}-tst100  -mul 1.0  ${datadir}/rf/${bids}-tst100 -odt float
    #/bin/rm  hum_${bids}/rf/${bids}-tst100.hdr
   #/bin/rm  hum_${bids}/rf/${bids}-tst100.img
fi

if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-tst100` -eq 0 ];then
    echo "Averaging 100 degree TSTEAM volumes"

    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-tst100-1` -eq 0 ];then
	echo "1st tst100 series does not exist or is not in a supported format"
	exit
    fi
    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-tst100-2` -eq 0 ];then
	echo "2nd tst100 series does not exist or is not in a supported format"
	exit
    fi

    fslmaths ${datadir}/rf/${bids}-tst100-1 -add ${datadir}/rf/${bids}-tst100-2 -div 2 ${datadir}/rf/${bids}-tst100 -odt float
fi

if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-bc-tst60` -eq 1 ];then

    fslmaths  ${datadir}/rf/${bids}-tst60  -mul 1.0  ${datadir}/rf/${bids}-bc-tst60  -odt float
   # /bin/rm  hum_${bids}/rf/${bids}-bc-tst60.hdr
   # /bin/rm  hum_${bids}/rf/${bids}-bc-tst60.img
fi

if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-bc-tst100` -eq 1 ];then

    avwmaths_32R  ${datadir}/rf/${bids}-bc-tst100  -mul 1.0  ${datadir}/rf/${bids}-bc-tst100
    #/bin/rm  hum_${bids}/rf/${bids}-bc-tst100.hdr
    #/bin/rm  hum_${bids}/rf/${bids}-bc-tst100.img
fi


echo "Registration to ACPC..."
echo ""

if [ `${FSLDIR}/bin/imtest ${datadir}/acpc/${bids}-tse` -eq 1 ];then

    echo "... 3D TSE and smooth"

    fslmaths  ${datadir}/rf/${bids}-tst60  -s 4.25  ${datadir}/rf/${bids}-tst60-lpf
#OBS! fslmaths  does not work with FSL3.2

    ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst60  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-tst60  -omat ${datadir}/acpc/${bids}-tst60.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear
  
  ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst60-lpf  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-tst60-msk  -applyxfm -init ${datadir}/acpc/${bids}-tst60.mat
#OBS! -msk naming dating back to old routines


    fslmaths  ${datadir}/rf/${bids}-tst100  -s 4.25  ${datadir}/rf/${bids}-tst100-lpf

    ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst100  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-tst100  -omat ${datadir}/acpc/${bids}-tst100.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear

  ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst100-lpf  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-tst100-msk  -applyxfm -init  ${datadir}/acpc/${bids}-tst100.mat


    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-bc-tst60` -eq 1 ];then

        fslmaths  ${datadir}/rf/${bids}-bc-tst60  -s 4.25  ${datadir}/rf/${bids}-bc-tst60-lpf

        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst60  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-bc-tst60  -omat ${datadir}/acpc/${bids}-bc-tst60.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear

  
        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst60-lpf  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-bc-tst60-msk  -applyxfm -init ${datadir}/acpc/${bids}-bc-tst60.mat
    fi


    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-bc-tst100` -eq 1 ];then

        fslmaths  ${datadir}/rf/${bids}-bc-tst100  -s 4.25  ${datadir}/rf/${bids}-bc-tst100-lpf

        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst100  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-bc-tst100  -omat ${datadir}/${project}/{vnum}/${bids}/acpc/${bids}-bc-tst100.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear
  
        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst100-lpf  -ref ${datadir}/acpc/${bids}-tse  -out ${datadir}/acpc/${bids}-bc-tst100-msk  -applyxfm -init ${datadir}/acpc/${bids}-bc-tst100.mat
    fi
fi


#if no TSE in /acpc then use TFL in acpc instead

if [ `${FSLDIR}/bin/imtest ${datadir}/acpc/${bids}-tse` -eq 0 ];then

    if [ `${FSLDIR}/bin/imtest ${datadir}/acpc/${bids}-tfl` -eq 1 ];then

        echo "... 3D TFL and smooth"

        fslmaths  ${datadir}/rf/${bids}-tst60  -s 4.25  ${datadir}/rf/${bids}-tst60-lpf
#OBS! avwconv does not work with FSL4.x

        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst60  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-tst60  -omat ${datadir}/acpc/${bids}-tst60.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear
  
  ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst60-lpf  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-tst60-msk  -applyxfm -init ${datadir}/acpc/${bids}-tst60.mat
#OBS! -msk dating back to old routines


    fslmaths  ${datadir}/rf/${bids}-tst100  -s 4.25  ${datadir}/rf/${bids}-tst100-lpf

    ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst100  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-tst100  -omat ${datadir}/acpc/${bids}-tst100.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear

  ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-tst100-lpf  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-tst100-msk  -applyxfm -init  ${datadir}/acpc/${bids}-tst100.mat


    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-bc-tst60` -eq 1 ];then

        fslmaths  ${datadir}/rf/${bids}-bc-tst60  -s 4.25  ${datadir}/rf/${bids}-bc-tst60-lpf

        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst60  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-bc-tst60  -omat ${datadir}/acpc/${bids}-bc-tst60.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear

        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst60-lpf  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-bc-tst60-msk  -applyxfm -init ${datadir}/acpc/${bids}-bc-tst60.mat
    fi


    if [ `${FSLDIR}/bin/imtest ${datadir}/rf/${bids}-bc-tst100` -eq 1 ];then

        fslmaths  ${datadir}/rf/${bids}-bc-tst100  -s 4.25  ${datadir}/rf/${bids}-bc-tst100-lpf

        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst100  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-bc-tst100  -omat ${datadir}/acpc/${bids}-bc-tst100.mat -bins 256 -cost mutualinfo -nosearch -dof 6 -interp trilinear
  
        ${FSLDIR}/bin/flirt  -in ${datadir}/rf/${bids}-bc-tst100-lpf  -ref ${datadir}/acpc/${bids}-tfl  -out ${datadir}/acpc/${bids}-bc-tst100-msk  -applyxfm -init ${datadir}/acpc/${bids}-bc-tst100.mat
    fi
    fi

fi

echo ""
echo "Now doing arithmetrics"

fslmaths ${datadir}/acpc/${bids}-tst60-msk -mul 100 -mul 0.01745329 ${datadir}/acpc/${bids}-tst60_l
fslmaths ${datadir}/acpc/${bids}-tst100-msk -mul 60 -mul 0.01745329 ${datadir}/acpc/${bids}-tst100_l
fslmaths ${datadir}/acpc/${bids}-tst100_l -sub ${datadir}/acpc/${bids}-tst60_l ${datadir}/acpc/${bids}-tst100-60_l

fslmaths ${datadir}/acpc/${bids}-tst60_l -mul 100 -mul 0.01745329 ${datadir}/acpc/${bids}-tst60_q
fslmaths ${datadir}/acpc/${bids}-tst100_l -mul 60 -mul 0.01745329 ${datadir}/acpc/${bids}-tst100_q
fslmaths ${datadir}/acpc/${bids}-tst100_q -sub ${datadir}/acpc/${bids}-tst60_q ${datadir}/acpc/${bids}-tst100-60_q

fslmaths ${datadir}/acpc/${bids}-tst100-msk -sub ${datadir}/acpc/${bids}-tst60-msk -mul $r -div ${datadir}/acpc/${bids}-tst100-60_q ${datadir}/acpc/${bids}-tst100-60_d

fslmaths ${datadir}/acpc/${bids}-tst100-60_l -div ${datadir}/acpc/${bids}-tst100-60_q  -mul $p ${datadir}/acpc/${bids}-tst100-60_r

fslmaths ${datadir}/acpc/${bids}-tst100-60_r -mul  ${datadir}/acpc/${bids}-tst100-60_r -sub ${datadir}/acpc/${bids}-tst100-60_d ${datadir}/acpc/${bids}_diskr

fslmaths ${datadir}/acpc/${bids}_diskr -sqrt -add ${datadir}/acpc/${bids}-tst100-60_r -div $q ${datadir}/acpc/${bids}_bias
fslmaths ${datadir}/acpc/${bids}_bias -thr 0 -uthr 4  ${datadir}/acpc/${bids}_bias

echo "Done thresholded flip angle bias [0 4]"

# calculate BC/HC ratio for correction of A(mplitude) to P(roton)D(ensity)

if [ `${FSLDIR}/bin/imtest ${datadir}/acpc/${bids}-bc-tst60` -eq 1 ];then

    fslmaths ${datadir}/acpc/${bids}-tst60-msk  -add ${datadir}/acpc/${bids}-tst100-msk  ${datadir}/acpc/${bids}-hc-msk
    fslmaths ${datadir}/acpc/${bids}-bc-tst60-msk  -add ${datadir}/acpc/${bids}-bc-tst100-msk  -div ${datadir}/acpc/${bids}-hc-msk  ${datadir}/acpc/${bids}_ratio
fi 

echo ""
echo "Cleaning up temporary maps"

/bin/rm   ${datadir}/acpc/${bids}-tst100-60_d.*  ${datadir}/acpc/${bids}-tst100-60_r.* ${datadir}/acpc/*_l.* ${datadir}/acpc/*_q.*  ${datadir}/acpc/${bids}*tst*msk.*   ${datadir}/acpc/${bids}_diskr.*

echo "Apply bias to FLASH-based parameter maps"
echo ""

fslmaths  ${datadir}/acpc/${bids}_T1  -div ${datadir}/acpc/${bids}_bias  -div ${datadir}/acpc/${bids}_bias  ${datadir}/acpc/${bids}_T1corr
fslmaths  ${datadir}/acpc/${bids}_R1  -mul ${datadir}/acpc/${bids}_bias  -mul ${datadir}/acpc/${bids}_bias  ${datadir}/acpc/${bids}_R1corr

if [ `${FSLDIR}/bin/imtest ${datadir}/acpc/${bids}_ratio` -eq 1 ];then

    fslmaths  ${datadir}/acpc/${bids}_A  -mul ${datadir}/acpc/${bids}_ratio  -div ${datadir}/acpc/${bids}_bias  -div ${datadir}/acpc/${bids}_bias  ${datadir}/acpc/${bids}_Acorr
fi

echo "Setting permissions for MRIcro uncompression.."
echo ""
#chmod 775 hum_${bids}/acpc/${bids}_T1corr.nii.gz
#chmod 775 hum_${bids}/acpc/${bids}_R1corr.nii.gz
#chmod 775 hum_${bids}/rf/*

if [ `${FSLDIR}/bin/imtest ${datadir}/acpc/${bids}_Acorr` -eq 1 ];then
    chmod 775 hum_${bids}/acpc/${bids}_Acorr.nii.gz
fi

echo "Mapping done"



