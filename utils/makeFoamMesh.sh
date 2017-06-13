#!/bin/bash 
caseindex=$1
portlogFile=$2
meshScript=$3
meshParamsFile=$4

meshDir=$5

fOut=$6
fErr=$7

######
SALOMEPATH=/home/marmar/programs-local/SALOME-8.2.0-UB14.04/
#####

WORK_DIR=$(pwd)
mkdir -p $meshDir
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir
salLogDir=$(dirname "${portlogFile}")
mkdir -p $salLogDir

# Generate the stl surfaces files using salome

printf 'Salome output\n------------\n' >> $fOut
printf 'Salome errors\n------------\n' >> $fErr
portlogFileAbsPath=${WORK_DIR}/$portlogFile 
$SALOMEPATH/salome start -t   --ns-port-log=$portlogFileAbsPath 1>>$fOut 2>>$fErr
$SALOMEPATH/salome shell -p `cat $portlogFileAbsPath`  $meshScript args:$meshParamsFile,$meshDir 1>>$fOut 2>>$fErr


