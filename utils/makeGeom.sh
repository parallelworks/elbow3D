#!/bin/bash 

geomScript=$1
paramsFile=$2

faomCaseDirPath=$3
caseDirPath=$4


fOut=$5
fErr=$6

echo $@  >> $fOut

WORK_DIR=$(pwd)
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

if [ "$embeddedDocker" = true ] ; then
	run_command="docker run --rm  -i -v `pwd`:/scratch -w /scratch -u $dockerUserID:$dockerGrpID parallelworks/salome:v8_2u /bin/bash"
else
    run_command="/bin/bash"
fi


# Copy and extract openFoam case files
foamDirName=$(basename "$faomCaseDirPath")
foamDirName="${foamDirName%%.*}"

mkdir -p $caseDirPath
cp -r $faomCaseDirPath $caseDirPath
meshDir=$caseDirPath/$foamDirName/constant/triSurface/
#sysDir=$caseDirPath/$foamDirName/system/


cd $caseDirPath/
touch $foamDirName.tar
cd $WORK_DIR


# Generate the stl surfaces files using salome

printf 'Salome output\n------------\n' >> $fOut
printf 'Salome errors\n------------\n' >> $fErr

####### !!! copy the required files for Salome to make them accessible in docker (?)
cp $geomScript geomScript_localCopy.py
geomScript=geomScript_localCopy.py
cp utils/data_IO.py . 

cp $paramsFile paramsFile_localCopy
paramsFile=paramsFile_localCopy
####### !!!

echo ${SALOMEPATH}salome start -t -w 1 $geomScript args:$paramsFile,$meshDir   > makeGeomRun.sh

echo $run_command >>$fOut
echo $embeddedDocker >>$fOut
printf '\nmakeGeomRun.sh \n------------\n' >> $fOut
cat makeGeomRun.sh >>$fOut

printf '\n------------\n' >> $fOut

chmod +x makeGeomRun.sh

$run_command makeGeomRun.sh 1>>$fOut 2>>$fErr 




