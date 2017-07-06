import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string sweepParamsFileName  = arg("sweepParamFile", "sweepParams.run");

file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

# directory definitions
string outDir               = "outputs/";
string errorsDir            = strcat(outDir, "errorFiles/");
string logsDir              = strcat(outDir, "logFiles/");
string simFilesDir          = strcat(outDir, "simParamFiles/");
string caseDirs         = strcat(outDir, "case"); 

# Script files and utilities
file geomScript             <"utils/elbow3D_inputFile.py">;
file metrics2extract        <"inputs/elbowKPI.json">;
file fFoamCase              <"inputs/openFoamCase.tar">;
file writeBlockMeshScript   <"utils/writeBlockMeshDictFile.py">;

file utils[] 		        <filesys_mapper;location="utils", pattern="?*.*">;

# ------ APP DEFINITIONS --------------------#

app (file cases, file[] simFileParams) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] utils) {
	python2 "utils/expandSweep.py" filename(sweepParams) filename(cases);
	python "utils/writeSimParamFiles.py" filename(cases) simFilesDir "caseParamFile";
}

app (file fcaseTar, file ferr, file fout) prepareCase (file geomScript, file utils[], 
                                                       file fsimParams, string caseDirPath, 
                                                       file writeBlockMeshScript, file fFoamCase) {
    makeGeom filename(geomScript) filename(fsimParams) filename(fFoamCase) 
             caseDirPath filename(fout) filename(ferr);
    makeMesh filename(fsimParams) filename(fFoamCase) caseDirPath filename(writeBlockMeshScript) 
             filename(fout) filename(ferr);
}

app (file MetricsOutput, file[] fpngs, file fOut, file fErr) runSimExtractMetrics (file fOpenCaseTar, 
                                                                                   file metrics2extract, 
                                                                                   string extractOutDir, 
                                                                                   file utils[]){
    runSim filename(fOpenCaseTar) filename(fOut) filename(fErr);
    PVExtract filename(fOpenCaseTar) filename(metrics2extract) extractOutDir filename(MetricsOutput) 
           filename(fOut) filename(fErr);

}


#----------------workflow-------------------#

# Read parameters from the sweepParams file and write to case files
file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils);


file[] fallFoamCaseDirs;
string[] caseDirPaths;
foreach fsimParams,i in simFileParams{
    file meshErr         <strcat(errorsDir, "mesh", i, ".err")>;                          
    file meshOut         <strcat(logsDir, "mesh", i, ".out")>;                          
    caseDirPaths[i] = strcat(caseDirs, i, "/");
    file fcaseTar     <strcat(caseDirPaths[i], "/openFoamCase.tar")>;
    (fcaseTar, meshErr, meshOut) = prepareCase(geomScript, utils, fsimParams, caseDirPaths[i],
                                                            writeBlockMeshScript, fFoamCase);
    fallFoamCaseDirs[i] = fcaseTar;
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


