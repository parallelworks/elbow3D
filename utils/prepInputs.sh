#!/bin/bash 
sweepParams=$1
casesListFile=$2
simFilesDir=$3
caseParamFileRootName=$4

python mexdex/prepinputs.py   --SR_valueDelimiter " "  \
	                          --SR_paramsDelimiter "\n" \
	                          --noParamTag \
	                          --CL_paramValueDelimiter "=" \
	                          $sweepParams $casesListFile 

python "utils/writeSimParamFiles.py" $casesListFile $simFilesDir $caseParamFileRootName
