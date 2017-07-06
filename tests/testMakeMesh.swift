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
file meshScript             <"utils/elbow3D_inputFile.py">;
file metrics2extract        <"inputs/beadOnPlateKPI_short.json">;

file utils[] 		        <filesys_mapper;location="utils", pattern="*.*">;

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

app (file meshDir[], file ferr, file fout, file salPort) makeMesh (file meshScript, int caseindex, file utils[], 
                                                               file fsimParams, string meshDirPath) {
    bash "utils/makeFoamMesh.sh" caseindex  filename(salPort) filename(meshScript) filename(fsimParams)
         meshDirPath filename(fout) filename(ferr);
}

app (file ferr, file fout) killSalomeInstance (file[] fmeshes, file salPort, file utils[]){
    bash "utils/killSalome.sh" filename(salPort)  stderr=filename(ferr) stdout=filename(fout); 
}

#----------------workflow-------------------#

# Read parameters from the sweepParams file and write to case files
file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fallMeshDirs[];
file[] salPortFiles;
foreach fsimParams,i in simFileParams{
# file fsimParams = simFileParams[0];
# int i =0;
    file fsalPortLog   <strcat(salPortsDir, "salomePort", i, ".log")>;
    file meshErr       <strcat(errorsDir, "mesh", i, ".err")>;                          
    file meshOut       <strcat(logsDir, "mesh", i, ".out")>;                          
    string meshDirPath=strcat(meshFilesDir, i, "/test/");
    file meshDir[]     <filesys_mapper; location = meshDirPath>;
    (meshDir, meshErr, meshOut, fsalPortLog) = makeMesh(meshScript, i, utils, fsimParams, meshDirPath);
    fallMeshDirs[i] = meshDir;
    salPortFiles[i] = fsalPortLog;
}
