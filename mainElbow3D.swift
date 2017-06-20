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
string caseDirs         = strcat(outDir, "case"); 

# Script files and utilities
file geomScript             <"utils/elbow3D_inputFile.py">;
file metrics2extract        <"inputs/elbowKPI.json">;
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

app (file fcaseTar, file ferr, file fout, file salPort) prepareCase (file geomScript, int caseindex, file utils[], 
                                                              file fsimParams, string caseDirPath, 
                                                              file writeBlockMeshScript, file fFoamCase) {
    bash "utils/preProcess.sh" caseindex  filename(salPort) filename(geomScript) filename(fsimParams) 
         filename(fFoamCase) caseDirPath filename(writeBlockMeshScript) filename(fout) filename(ferr);
}

app (file ferr, file fout) killSalomeInstance (file[] fmeshes, file salPort, file utils[]){
    bash "utils/killSalome.sh" filename(salPort)  stderr=filename(ferr) stdout=filename(fout); 
}

app (file MetricsOutput, file[] fpngs, file fOut, file fErr) runSimExtractMetrics (file fOpenCaseTar, 
                                                                                   file metrics2extract, 
                                                                                   string extractOutDir, 
                                                                                   file utils[]){
    bash "utils/runSimPVExtract.sh" filename(fOpenCaseTar) filename(metrics2extract) extractOutDir
          filename(MetricsOutput) filename(fOut) filename(fErr);
}


#----------------workflow-------------------#

# Read parameters from the sweepParams file and write to case files
file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fallFoamCaseDirs;
file[] salPortFiles;
string[] caseDirPaths;
foreach fsimParams,i in simFileParams{
    file fsalPortLog     <strcat(salPortsDir, "salomePort", i, ".log")>;
    file meshErr         <strcat(errorsDir, "mesh", i, ".err")>;                          
    file meshOut         <strcat(logsDir, "mesh", i, ".out")>;                          
    caseDirPaths[i] = strcat(caseDirs, i, "/");
    file fcaseTar     <strcat(caseDirPaths[i], "/openFoamCase.tar")>;
    (fcaseTar, meshErr, meshOut, fsalPortLog) = prepareCase(geomScript, i, utils, fsimParams, caseDirPaths[i],
                                                            writeBlockMeshScript, fFoamCase);
    fallFoamCaseDirs[i] = fcaseTar;
    salPortFiles[i] = fsalPortLog;
}


# Terminate Salome instances after done with generating all mesh files
foreach fsalPort,i in salPortFiles{
    file salKillErr     <strcat(errorsDir, "salomeKill",i,".err")>;                          
    file salKillOut     <strcat(logsDir, "salomeKill",i,".out")>;                          
    (salKillErr, salKillOut) =  killSalomeInstance(fallFoamCaseDirs,  fsalPort, utils);
}

# Run openFoam and extract metrics for each case
foreach fOpenCaseTar,i in fallFoamCaseDirs{
    file MetricsOutput  <strcat(caseDirPaths[i], "metrics.csv")>;
    string extractOutDir = strcat(outDir,"png/",i,"/");
    file fextractPng[]	 <filesys_mapper;location=extractOutDir>;	
	file fRunOut       <strcat(logsDir, "extractRun", i, ".out")>;
	file fRunErr       <strcat(errorsDir, "extractRun", i ,".err")>;
    
    (MetricsOutput, fextractPng, fRunOut, fRunErr) = runSimExtractMetrics(fOpenCaseTar, metrics2extract,
                                                                                extractOutDir, utils);
}


