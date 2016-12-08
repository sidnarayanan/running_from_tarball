#!/bin/bash


export TARBALLDIR="/work/bmaier/production/running_from_tarball"
export BASEDIR=${PWD}
rm -r work_${1}
mkdir work_${1}
export SUBMIT_WORKDIR=${PWD}/work_${1}

#copying necessary inputs
echo "TARBALL=${1}_tarball.tar.xz" > ./submit/inputs.sh
echo "HADRONIZER=${1}_hadronizer.py" >> ./submit/inputs.sh
echo "PROCESS=${1}" >> ./submit/inputs.sh
echo "USERNAME=${USER}" >> ./submit/inputs.sh

if [ -z "$2" ]
    then
    echo "MERGE=0" >> ./submit/inputs.sh
    echo "You want to produce events for $1. Good luck!"
else
    echo "MERGE=1" >> ./submit/inputs.sh
    echo "You want to merge the T2 files for $1? Ok."
fi

mkdir -p ./submit/input/
cp ${TARBALLDIR}/inputs/${1}_tarball.tar.xz ./submit/input/
cp ${TARBALLDIR}/inputs/${1}_hadronizer.py ./submit/input/
cp inputs/copy.tar ./submit/input/
cp inputs/aod_template.py ./submit/input/
cp inputs/pu_files.py ./submit/input/

#x509
voms-proxy-init -voms cms -valid 172:00
cp /tmp/x509up_u$UID $SUBMIT_WORKDIR/x509up

#creating tarball
echo "Tarring up submit..."
tar -chzf submit.tgz submit 
rm -r ${BASEDIR}/submit/input/*

mv submit.tgz $SUBMIT_WORKDIR

cp ${BASEDIR}/exec.sh $SUBMIT_WORKDIR

#does everything look okay?
ls -l $SUBMIT_WORKDIR
