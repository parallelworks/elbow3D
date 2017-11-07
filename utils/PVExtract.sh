#!/bin/bash 
openCaseTarAddress=$1 
openCaseResultsTarAddress=$2

desiredMetricsFile=$3
pvOutputDir=$4
outputMetrics=$5
saveSimResults=$6

fOut=$7
fErr=$8


if [ "$embeddedDocker" = true ] ; then
	run_command="docker run --rm -i -v `pwd`:/scratch -w /scratch -u 0:0 parallelworks/paraview:v5_4u_imgmagick   /bin/bash" 
	PARAVIEWPATH=""
else
    run_command="/bin/bash"
fi

echo $run_command


errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

WORK_DIR=$(pwd)

pvpythonExtractScript=mexdex/extract.py

caseDirPath=$(dirname "${openCaseTarAddress}")
openFoamTar=$(basename "$openCaseTarAddress")
foamDirName="${openFoamTar%%.*}"
controlDictFile=$caseDirPath/$foamDirName/system/controlDict

####### !!! copy the required files for python3 to make them accessible in docker (?)
if [ "$embeddedDocker" = true ] ; then
 	cp $pvpythonExtractScript pvpythonExtractScript_localCopy.py
	pvpythonExtractScript=pvpythonExtractScript_localCopy.py
	cp mexdex/data_IO.py . 
	cp mexdex/pvutils.py .
	cp mexdex/metricsJsonUtils.py .
fi 
####### !!!

# Extract metrics from results file
printf 'pvpython output\n------------\n' >> $fOut
printf 'pvpython errors\n------------\n' >> $fErr

echo xvfb-run -a --server-args=\"-screen 0 1024x768x24\" ${PARAVIEWPATH}pvpython --mesa-llvm  $pvpythonExtractScript  $controlDictFile $desiredMetricsFile  $pvOutputDir $outputMetrics > pvpythonRun.sh

printf '\npvpythonRun.sh \n------------\n' >> $fOut
cat pvpythonRun.sh >>$fOut
printf '\n------------\n' >> $fOut

chmod +x pvpythonRun.sh

$run_command pvpythonRun.sh  1>>$fOut 2>>$fErr

echo saveSimResults= >> $fOut
echo $saveSimResults >> $fOut
if [ "$saveSimResults" = true ] ; then
	cd $caseDirPath/
	rm $openFoamTar
	tar -cf $foamDirName.tar $foamDirName
	cd $WORK_DIR
fi
cp $caseDirPath/$foamDirName.tar $openCaseResultsTarAddress
