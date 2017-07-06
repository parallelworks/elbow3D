#!/bin/bash 
paramsFile=$1

foamCaseTar=$2
caseDirPath=$3

writeBlockMeshDictScript=$4 

fOut=$5
fErr=$6


if [ "$embeddedDocker" = true ] ; then
	run_command="docker run --rm  -i   -v `pwd`:/scratch -w /scratch   -u $(id -u):$(id -g) marmarm/openfoam:v4_1 /bin/bash" 
else
    run_command="/bin/bash"
fi

WORK_DIR=$(pwd)
errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

# Copy and extract openFoam case files
foamDirName=$(basename "$foamCaseTar")
foamDirName="${foamDirName%%.*}"

meshDir=$caseDirPath/$foamDirName/constant/triSurface/
sysDir=$caseDirPath/$foamDirName/system/

#
# Generate Mesh using openFOAM tools
# 

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


echo source $OPENFOAMPATH/etc/bashrc \"\"                         > makeMeshRun.sh

# Overwrite blockMeshDict file based on bounding box dimension of the input  stl file

####### !!! copy the required files for python3 to make them accessible in docker (?)
if [ "$embeddedDocker" = true ] ; then
 	cp $writeBlockMeshDictScript writeBlockMeshDictScript_localCopy.py
	writeBlockMeshDictScript=writeBlockMeshDictScript_localCopy.py
	cp utils/data_IO.py . 
	cp utils/foamutils.py .
fi 
####### !!!

echo python3 $writeBlockMeshDictScript  $meshDir/walls.stl $sysDir >> makeMeshRun.sh

# Generate line emesh files for sharper edges
echo surfaceFeatureExtract -case  $caseDirPath/$foamDirName/      >> makeMeshRun.sh

echo blockMesh -case  $caseDirPath/$foamDirName/                  >> makeMeshRun.sh                  

echo snappyHexMesh -overwrite -case   $caseDirPath/$foamDirName/  >> makeMeshRun.sh

printf '\nmakeMeshRun.sh \n------------\n' >> $fOut
cat makeMeshRun.sh >>$fOut
printf '\n------------\n' >> $fOut

chmod +x makeMeshRun.sh

$run_command makeMeshRun.sh 1>>$fOut 2>>$fErr 

cp  $caseDirPath/$foamDirName/constant/polyMesh/boundary  $caseDirPath/$foamDirName/constant/polyMesh/boundary.orig

python utils/writeBoundaryFile.py $caseDirPath/$foamDirName/constant/polyMesh/    $caseDirPath/$foamDirName/constant/polyMesh/boundary.ref 1>>$fOut 2>>$fErr 

cd $caseDirPath/
tar -cf $foamDirName.tar $foamDirName
cd $WORK_DIR

