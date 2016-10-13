#!/bin/bash

WHAT=$1; 
if [ "$#" -ne 1 ]; then 
    echo "steerTOPUE.sh <SEL/MERGESEL/PLOTSEL/WWWSEL>";
    echo "        SEL          - launches selection jobs to the batch, output will contain summary trees and control plots"; 
    echo "        MERGESEL     - merge the output of the jobs";
    echo "        PLOTSEL      - runs the plotter tool on the selection";
    echo "        WWWSEL       - moves the plots to an afs-web-based area";
    exit 1; 
fi

export LSB_JOB_REPORT_MAIL=N


queue=2nw
githash=8db9ad6
lumi=12870
lumiSpecs="--lumiSpecs EE:11391"
lumiUnc=0.062
whoami=`whoami`
myletter=${whoami:0:1}
eosdir=/store/cmst3/user/psilva/LJets2016/${githash}
summaryeosdir=/store/cmst3/group/top/summer2016/TopWidth_era2016_ichep
outdir=/afs/cern.ch/work/${myletter}/${whoami}/TopUE_era2016/
wwwdir=~/www/TopUE_era2016/


RED='\e[31m'
NC='\e[0m'
case $WHAT in
    SEL )
	queue=local;
	python scripts/runLocalAnalysis.py -i ${eosdir} -q ${queue} -o ${outdir} --era era2016 -m TOP-UE::RunTopUE --ch 0 --runSysts --only dilpowheg;
	;;
    MERGESEL )
	./scripts/mergeOutputs.py ${outdir} True;	
	;;
    PLOTSEL )
	python scripts/plotter.py -i ${outdir} --puNormSF puwgtctr  -j data/era2016/samples.json -l ${lumi} ${lumiSpecs} --saveLog --mcUnc ${lumiUnc};	
	;;
    WWWSEL )
	mkdir -p ${wwwdir}/sel
	cp ${outdir}/plots/*.{png,pdf} ${wwwdir}/sel
	cp test/index.php ${wwwdir}/sel
	;;
    ANA )
	#python test/TopUEAnalysis/runUEanalysis.py -i ${outdir}/MC13TeV_TTJets_dilpowheg_0.root --step 1;
	#python test/TopUEAnalysis/runUEanalysis.py -i ${outdir}/MC13TeV_TTJets_dilpowheg_*.root --step 2;
	python test/TopUEAnalysis/runUEanalysis.py --step 3;
	;;

esac