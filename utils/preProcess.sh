#!/bin/bash 
portlogFile=$1
meshScript=$2
paramsFile=$3

foamCaseTar=$4
caseDirPath=$5

#new 
writeBlockMeshDictScript=$6 #writeBlockMeshDictFile.py

fOut=$7
fErr=$8

######
# SALOMEPATH=/home/marmar/programs-local/SALOME-8.2.0-UB14.04/
# OPENFOAMPATH=/opt/openfoam4/
#####


WORK_DIR=$(pwd)
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir
salLogDir=$(dirname "${portlogFile}")
mkdir -p $salLogDir


# Copy and extract openFoam case files
foamDirName=$(basename "$foamCaseTar")
foamDirName="${foamDirName%%.*}"

mkdir -p $caseDirPath
cp $foamCaseTar $caseDirPath
tar -xf $caseDirPath/$foamDirName.tar -C $caseDirPath
meshDir=$caseDirPath/$foamDirName/constant/triSurface/
sysDir=$caseDirPath/$foamDirName/system/

# Generate the stl surfaces files using salome

printf 'Salome output\n------------\n' >> $fOut
printf 'Salome errors\n------------\n' >> $fErr
portlogFileAbsPath=${WORK_DIR}/$portlogFile 
$SALOMEPATH/salome start -t   --ns-port-log=$portlogFileAbsPath 1>>$fOut 2>>$fErr
$SALOMEPATH/salome shell -p `cat $portlogFileAbsPath`  $meshScript args:$paramsFile,$meshDir 1>>$fOut 2>>$fErr

source $OPENFOAMPATH/etc/bashrc ""


# Replace the paramaters in the case files with values from $paramsFiles

params=$(<$paramsFile)
read -a paramcut <<< $params
echo Parameter Length: "${#paramcut[@]}"
for (( c=0; c<${#paramcut[@]}; c=c+2 ))
do
    pname=${paramcut[$c]}
    pval=${paramcut[$c+1]}
	find $caseDirPath/$foamDirName   -type f -exec sed -i "s/@@$pname@@/$pval/g" {} \;
done

# Generate line emesh files for sharper edges

# Overwrite blockMeshDict file based on bounding box dimension of the input  stl file
python3 $writeBlockMeshDictScript $meshDir/walls.stl $sysDir

surfaceFeatureExtract -case  $caseDirPath/$foamDirName/  1>>$fOut 2>>$fErr

blockMesh -case  $caseDirPath/$foamDirName/ 1>>$fOut 2>>$fErr

snappyHexMesh -overwrite -case   $caseDirPath/$foamDirName/ 1>>$fOut 2>>$fErr 

cp  $caseDirPath/$foamDirName/constant/polyMesh/boundary  $caseDirPath/$foamDirName/constant/polyMesh/boundary.orig

python utils/writeBoundaryFile.py $caseDirPath/$foamDirName/constant/polyMesh/    $caseDirPath/$foamDirName/constant/polyMesh/boundary.ref 1>>$fOut 2>>$fErr 

cd $caseDirPath/
tar -cf $foamDirName.tar $foamDirName
cd $WORK_DIR

