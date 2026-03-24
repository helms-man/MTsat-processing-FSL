#!/bin/sh

datadir="/media/sf_Projects"
datadir="/media/sf_MRI-Data/Projects"

project=${1}

datadir=${datadir}/${project}
#/${vnum}/${hum_num}
#bids=${vnum}_${hum_num}
#echo ${datadir}
search_dir=/the/path/to/base/dir
for entry in $(ls $datadir)
do
  vnum="$entry"
  echo $vnum
  for entry in $(ls $datadir/$vnum)
  do
    hum=$entry
    echo $hum
    if test -d $datadir/$vnum/$hum; then
        dwidir=$datadir/$vnum/$hum
        bids=${vnum}_${hum}
        if ! test -f $datadir/$vnum/$hum/acpc/*MT.nii.gz; then
            echo 'acpc not exists'
        fi
    fi
    done
done