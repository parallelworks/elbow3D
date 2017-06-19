import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string sweepParamsFileName  = arg("sweepParamFile", "sweepParams.run");

file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

# directory definitions
string outDir               = "outputs/";
string errorsDir            = strcat(outDir, "errorFiles/");
string logsDir              = strcat(outDir, "logFiles/");
string salPortsDir          = strcat(logsDir, "salPortNums/");
string simFilesDir          = strcat(outDir, "simParamFiles/");
#string meshFilesDir         = strcat(outDir, "meshFiles/case");  
string meshFilesDir         = strcat(outDir, "case"); 

# Script files and utilities
file geomScript             <"utils/elbow3D_inputFile.py">;
file metrics2extract        <"inputs/beadOnPlateKPI_short.json">;
file fFoamCase              <"inputs/openFoamCase.tar">;
file writeBlockMeshScript   <"utils/writeBlockMeshDictFile.py">;

file utils[] 		        <filesys_mapper;location="utils", pattern="?*.*">;

# ------- Funciton definitions--------------#

(string nameNoSuffix) trimSuffix (string nameWithSuffix){
   int suffixStartLoc = lastIndexOf(nameWithSuffix, ".", -1);
   nameNoSuffix = substring(nameWithSuffix, 0, suffixStartLoc); 
}

# ------ APP DEFINITIONS --------------------#

app (file cases, file[] simFileParams) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir "caseParamFile";
}

app (file fmeshOutTar, file ferr, file fout, file salPort) prepareCase (file geomScript, int caseindex, file utils[], 
                                                              file fsimParams, string caseDirPath, 
                                                              file writeBlockMeshScript, file fFoamCase) {
    bash "utils/preProcess.sh" caseindex  filename(salPort) filename(geomScript) filename(fsimParams) 
         filename(fFoamCase) caseDirPath filename(writeBlockMeshScript) filename(fout) filename(ferr);
}

app (file ferr, file fout) killSalomeInstance (file[] fmeshes, file salPort, file utils[]){
    bash "utils/killSalome.sh" filename(salPort)  stderr=filename(ferr) stdout=filename(fout); 
}

#----------------workflow-------------------#

# Read parameters from the sweepParams file and write to case files
file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fallMeshDirs;
file[] salPortFiles;
foreach fsimParams,i in simFileParams{
    file fsalPortLog     <strcat(salPortsDir, "salomePort", i, ".log")>;
    file meshErr         <strcat(errorsDir, "mesh", i, ".err")>;                          
    file meshOut         <strcat(logsDir, "mesh", i, ".out")>;                          
    string caseDirPath = strcat(meshFilesDir, i);
    file fmeshOutTar     <strcat(caseDirPath, "/openFoamCase.tar")>;
    (fmeshOutTar, meshErr, meshOut, fsalPortLog) = prepareCase(geomScript, i, utils, fsimParams, caseDirPath, 
                                                            writeBlockMeshScript, fFoamCase);
    fallMeshDirs[i] = fmeshOutTar;
    salPortFiles[i] = fsalPortLog;
}


# Terminate Salome instances after done with generating all mesh files
foreach fsalPort,i in salPortFiles{
    file salKillErr     <strcat(errorsDir, "salomeKill",i,".err")>;                          
    file salKillOut     <strcat(logsDir, "salomeKill",i,".out")>;                          
    (salKillErr, salKillOut) =  killSalomeInstance(fallMeshDirs,  fsalPort, utils);
}


