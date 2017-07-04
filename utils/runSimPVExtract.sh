#!/bin/bash 
openCaseTarAddress=$1 

desiredMetricsFile=$2
pvOutputDir=$3
outputMetrics=$4

fOut=$5
fErr=$6

errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

WORK_DIR=$(pwd)

pvpythonExtractScript=utils/extract.py

# PARAVIEWPATH="/home/marmar/programs-local/ParaView-5.3.0-Qt5-OpenGL2-MPI-Linux-64bit/bin/"
# OPENFOAMPATH=/opt/openfoam4/

caseDirPath=$(dirname "${openCaseTarAddress}")
openFoamTar=$(basename "$openCaseTarAddress")
foamDirName="${openFoamTar%%.*}"

# untar the openFoam case directory
cd $caseDirPath
tar -xf $openFoamTar
cd $WORK_DIR

# Run openFoam simulation
printf 'pimpleFoam output\n------------\n' >> $fOut
printf 'pimpleFoam errors\n------------\n' >> $fErr
(source $OPENFOAMPATH/etc/bashrc ""
pimpleFoam -case  $caseDirPath/$foamDirName/ 1>>$fOut 2>>$fErr 
)

# Extract metrics from results file
printf 'pvpython output\n------------\n' >> $fOut
printf 'pvpython errors\n------------\n' >> $fErr
controlDictFile=$caseDirPath/$foamDirName/system/controlDict

xvfb-run -a --server-args="-screen 0 1024x768x24" $PARAVIEWPATH/pvpython --mesa-llvm  $pvpythonExtractScript  $controlDictFile $desiredMetricsFile  $pvOutputDir $outputMetrics 1>>$fOut 2>>$fErr

