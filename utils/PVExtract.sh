#!/bin/bash 
openCaseTarAddress=$1 

desiredMetricsFile=$2
pvOutputDir=$3
outputMetrics=$4

fOut=$5
fErr=$6

if [ "$embeddedDocker" = true ] ; then
	run_command="docker run --rm -i -v `pwd`:/scratch -w /scratch -u $(id -u):$(id -g) marmarm/paraview:v5_4u_imgmagick   /bin/bash" 
else
    run_command="/bin/bash"
fi



errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

WORK_DIR=$(pwd)

pvpythonExtractScript=utils/extract.py

caseDirPath=$(dirname "${openCaseTarAddress}")
openFoamTar=$(basename "$openCaseTarAddress")
foamDirName="${openFoamTar%%.*}"
controlDictFile=$caseDirPath/$foamDirName/system/controlDict

####### !!! copy the required files for python3 to make them accessible in docker (?)
if [ "$embeddedDocker" = true ] ; then
 	cp $pvpythonExtractScript pvpythonExtractScript_localCopy.py
	pvpythonExtractScript=pvpythonExtractScript_localCopy.py
	cp utils/data_IO.py . 
	cp utils/pvutils.py .
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
