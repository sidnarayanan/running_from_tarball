#!/bin/bash

###########
# setup
export BASEDIR=`pwd`


############
# inputs

export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
source $VO_CMS_SW_DIR/cmsset_default.sh
source inputs.sh
BASE=/cms/store/user/${USERNAME}
echo "Generating mediator mass " ${MASS}
#
#############
# make a working area

echo " Start to work now"
pwd
mkdir -p ./work
cd    ./work
export WORKDIR=`pwd`

#
#############
#############
# generate LHEs

export SCRAM_ARCH=slc6_amd64_gcc481
CMSSWRELEASE=CMSSW_7_1_20_patch3
scram p CMSSW $CMSSWRELEASE
cd $CMSSWRELEASE/src
mkdir -p Configuration/GenProduction/python/
cp ${BASEDIR}/input/${HADRONIZER} Configuration/GenProduction/python/
scram b -j 1
eval `scram runtime -sh`
cd -

tar xvaf ${BASEDIR}/input/${TARBALL}

sed -i 's/exit 0//g' runcmsgrid.sh

ls -lhrt

#RANDOMSEED=`od -vAn -N4 -tu4 < /dev/urandom`
#RANDOMSEED=${RANDOM}

RANDOMSEED1=${RANDOM}
RANDOMSEED2=${RANDOM}

RANDOMSEED="$((RANDOMSEED1 * RANDOMSEED2))"

if [ ${#RANDOMSEED} -gt "4" ];then
    RANDOMSEED=`echo $RANDOMSEED | rev | cut -c 4- | rev`
fi

. runcmsgrid.sh 1000 ${RANDOMSEED} 1


outfilename_tmp="$PROCESS"'_'"$RANDOMSEED"
outfilename="${outfilename_tmp//[[:space:]]/}"

mv cmsgrid_final.lhe ${outfilename}.lhe


ls -lhrt
#
#############
#############
# Generate GEN-SIM

cmsDriver.py Configuration/GenProduction/python/${HADRONIZER} --filein file:${outfilename}.lhe --fileout file:${outfilename}_gensim.root --mc --eventcontent RAWSIM --customise SLHCUpgradeSimulations/Configuration/postLS1Customs.customisePostLS1,Configuration/DataProcessing/Utils.addMonitoring --datatier GEN-SIM --conditions MCRUN2_71_V1::All --beamspot Realistic50ns13TeVCollision --step GEN,SIM --magField 38T_PostLS1 --python_filename ${outfilename}_gensim.py --no_exec -n 10

cmsRun ${outfilename}_gensim.py

#
############
############
# Generate AOD

export SCRAM_ARCH=slc6_amd64_gcc530
scram p CMSSW CMSSW_8_0_21
cd CMSSW_8_0_21/src
eval `scram runtime -sh`
cd -

cp ${BASEDIR}/input/pu_files.py .
cp ${BASEDIR}/input/aod_template.py .

sed -i 's/XX-GENSIM-XX/'${outfilename}'/g' aod_template.py
sed -i 's/XX-AODFILE-XX/'${outfilename}'/g' aod_template.py

mv aod_template.py ${outfilename}_1_cfg.py

cmsRun ${outfilename}_1_cfg.py

cmsDriver.py step2 --filein file:${outfilename}_step1.root --fileout file:${outfilename}_aod.root --mc --eventcontent AODSIM --runUnscheduled --datatier AODSIM --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step RAW2DIGI,RECO,EI --nThreads 1 --era Run2_2016 --python_filename ${outfilename}_2_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 1000

cmsRun ${outfilename}_2_cfg.py

#
###########
###########
# Generate MiniAODv2

cmsDriver.py step1 --filein file:${outfilename}_aod.root --fileout file:${outfilename}_miniaod.root --mc --eventcontent MINIAODSIM --runUnscheduled --datatier MINIAODSIM --conditions 80X_mcRun2_asymptotic_2016_TrancheIV_v6 --step PAT --nThreads 1 --era Run2_2016 --python_filename ${outfilename}_miniaod_cfg.py --no_exec --customise Configuration/DataProcessing/Utils.addMonitoring -n 1000

cmsRun ${outfilename}_miniaod_cfg.py

ls -lrht

lcg-cp -v -D srmv2 -b file://$PWD/${outfilename}_miniaod.root srm://t3serv006.mit.edu:8443/${BASE}/$USERNAME/$PROCESS/${outfilename}_miniaod.root

tar xf ${BASEDIR}/input/copy.tar

./cmscp.py \
  --debug \
  --destination srm://$SERVER:8443/${BASE}/$USERNAME/$PROCESS \
  --inputFileList ${outfilename}_miniaod.root \
  --middleware OSG \
  --PNN $SERVER \
  --se_name $SERVER \
  --for_lfn ${USERNAME}/${PROCESS}

echo "DONE."
