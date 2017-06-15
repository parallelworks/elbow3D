
mkdir tmp
cd tmp/
cp ~/Dropbox/parallelWorks/flow/elbow3D_workflow/outputs/case1/openFoamCase/constant.tar .
tar -xf constant.tar
cd ../

mkdir constant
cp -r tmp/constant/triSurface/ constant/

cp ~/Dropbox/parallelWorks/flow/elbow3D_workflow/inputs/openFoamCase.tar tmp/
cd tmp/
tar -xf openFoamCase.tar
cd ../
cp -r tmp/openFoamCase/system/ .

##### Fix this 
cp ../test72/system/blockMeshDict system/
surfaceFeatureExtract 
blockMesh 
snappyHexMesh -overwrite
cp -r tmp/openFoamCase/0/ .
##### Fix this 
cp ../test72/constant/polyMesh/boundary constant/polyMesh/
cd tmp/openFoamCase/constant/
cp dynamicMeshDict MRFProperties transportProperties turbulenceProperties ../../../constant/
cd ../../..
pimpleFoam 

