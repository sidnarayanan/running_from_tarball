#!/bin/bash


export TARBALLDIR="/work/bmaier/production/running_from_tarball"
export BASEDIR=${PWD}

# sanity check - does the input exist? if not, fail
INPUTTAR=${TARBALLDIR}/inputs/${1}_tarball.tar.xz
INPUTHAD=${TARBALLDIR}/inputs/${1}_hadronizer.py
if [ ! -f ${INPUTTAR} ]
then
  echo "ERROR: could not find ${INPUTTAR}"
  exit 1
fi
if [ ! -f ${INPUTHAD} ]
then
  echo "ERROR: could not find ${INPUTHAD}"
  exit 1
fi

rm -rf work_${1}
mkdir work_${1}
mkdir -p logs
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
cp ${INPUTTAR} ./submit/input/
cp ${INPUTHAD} ./submit/input/
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
