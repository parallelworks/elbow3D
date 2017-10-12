import "stdlib.v2";

type file;

# ------ INPUT / OUTPUT DEFINITIONS -------#

string sweepParamsFileName  = arg("sweepParamFile", "sweepParams_fast2.run");

file fsweepParams		    <strcat("inputs/",sweepParamsFileName)>;

# directory definitions
string outDir               = "outputs/";
string errorsDir            = strcat(outDir, "errorFiles/");
string logsDir              = strcat(outDir, "logFiles/");
string simFilesDir          = strcat(outDir, "simParamFiles/");
string caseDirs             = strcat(outDir, "case");

# Script files and utilities
file geomScript             <"utils/elbow3D_SalomeGeom.py">;
file metrics2extract        <"utils/elbowKPI.json">;
string fFoamCaseRootPath    = "openFoamCase";
file[] fFoamCase            <Ext; exec = "utils/mapper.sh", root = fFoamCaseRootPath>;
file writeBlockMeshScript   <"utils/writeBlockMeshDictFile.py">;

file utils[] 		        <filesys_mapper;location="utils", pattern="?*.*">;
file mexdex[] 		        <filesys_mapper;location="mexdex", pattern="?*.*">;

string runPath = getEnv("PWD");


# ------ APP DEFINITIONS --------------------#

app (file cases, file[] simFileParams) writeCaseParamFiles (file sweepParams, string simFilesDir, file[] utils, file[] mexdex) {
    bash "utils/prepInputs.sh"  filename(sweepParams) filename(cases) simFilesDir "caseParamFile";
}

app (file fcaseTar, file ferr, file fout) prepareCase (file geomScript, file utils[], file fsimParams, string caseDirPath, file writeBlockMeshScript, string fFoamCaseRootPath, file[] fFoamCase) {
    bash "utils/makeGeom.sh"  filename(geomScript) filename(fsimParams) fFoamCaseRootPath caseDirPath filename(fout) filename(ferr);
    bash "utils/makeMesh.sh" filename(fsimParams) fFoamCaseRootPath caseDirPath filename(writeBlockMeshScript) filename(fout) filename(ferr);
}

app (file MetricsOutput, file[] fpngs, file fOut, file fErr) runSimExtractMetrics (file fOpenCaseTar, file metrics2extract, string extractOutDir, file utils[], file mexdex[]){
    bash "utils/runSim.sh"  filename(fOpenCaseTar) filename(fOut) filename(fErr);
    bash "utils/PVExtract.sh" filename(fOpenCaseTar) filename(metrics2extract) extractOutDir filename(MetricsOutput) filename(fOut) filename(fErr);
}

#----------------workflow-------------------#

# Read parameters from the sweepParams file and write to case files
file caseFile 	            <strcat(outDir,"cases.list")>;
file[] simFileParams        <filesys_mapper; location = simFilesDir>;
(caseFile, simFileParams) = writeCaseParamFiles(fsweepParams, simFilesDir, utils, mexdex);

# Generate geometry and mesh for each case
file[] fallFoamCaseDirs;
string[] caseDirPaths;
foreach fsimParams,i in simFileParams{
    file meshErr         <strcat(errorsDir, "mesh", i, ".err")>;
    file meshOut         <strcat(logsDir, "mesh", i, ".out")>;
    caseDirPaths[i] = strcat(caseDirs, i, "/");
    file fcaseTar     <strcat(caseDirPaths[i], "/openFoamCase.tar")>;
    (fcaseTar, meshErr, meshOut) = prepareCase(geomScript, utils, fsimParams, caseDirPaths[i], writeBlockMeshScript, fFoamCaseRootPath, fFoamCase);
    fallFoamCaseDirs[i] = fcaseTar;
}

# Run openFoam and extract metrics for each case
file [][] allCasesPngs;
foreach fOpenCaseTar,i in fallFoamCaseDirs{
    file MetricsOutput  <strcat(caseDirPaths[i], "metrics.csv")>;
    string extractOutDir = strcat(outDir,"png/",i,"/");
    file fcasePngs[]	 <filesys_mapper;location=extractOutDir>;
	file fRunOut       <strcat(logsDir, "extractRun", i, ".out")>;
	file fRunErr       <strcat(errorsDir, "extractRun", i ,".err")>;
    
    (MetricsOutput, fcasePngs, fRunOut, fRunErr) = runSimExtractMetrics(fOpenCaseTar, metrics2extract, extractOutDir, utils, mexdex);
    allCasesPngs[i] = fcasePngs;
}
