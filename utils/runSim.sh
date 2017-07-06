#!/bin/bash 
openCaseTarAddress=$1 

fOut=$2
fErr=$3


if [ "$embeddedDocker" = true ] ; then
	run_command="docker run --rm -i -v `pwd`:/scratch -w /scratch -u $(id -u):$(id -g) marmarm/openfoam:v4_1 /bin/bash" 
else
    run_command="/bin/bash"
fi


errDir=$(dirname "${fErr}")
mkdir -p $errDir
fOutDir=$(dirname "${fOut}")
mkdir -p $fOutDir

WORK_DIR=$(pwd)

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

echo source $OPENFOAMPATH/etc/bashrc \"\"                         > runSimCommands.sh
echo pimpleFoam -case  $caseDirPath/$foamDirName/                 >> runSimCommands.sh

printf '\nrunSimCommands.sh \n------------\n' >> $fOut
cat runSimCommands.sh >>$fOut
printf '\n------------\n' >> $fOut

chmod +x runSimCommands.sh

$run_command runSimCommands.sh 1>>$fOut 2>>$fErr 


