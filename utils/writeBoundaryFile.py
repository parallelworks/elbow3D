import foamutils
import data_IO
import sys


# Input arguments:

if len(sys.argv) < 3:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeBoundaryFile.py <boundaryFilePath> <boundaryRefFile>")
    sys.exit()

boundaryFilePath = sys.argv[1]
boundaryRefFile = sys.argv[2]
print(boundaryRefFile)
print(boundaryFilePath)

import time
time.sleep(1)
# Read correct boundary types from the boundary reference file:

bfRef = data_IO.open_file(boundaryRefFile)
nBnds, bndDefStartLine = foamutils.getNumBoundariesFromFile(bfRef)
bndInfo = foamutils.getBoundaryTypesFromFile(bfRef, bndDefStartLine)


# Read mesh data from the auto generated boundary file
bfMeshData = data_IO.open_file(boundaryFilePath + 'boundary','r+')

for boundary in bndInfo:
    nFaces, startFace = foamutils.getBoundaryMeshInfo(boundary, bfMeshData)
    bndInfo[boundary]['nFaces'] = nFaces
    bndInfo[boundary]['startFace'] = startFace


# Overwrite the auto generated boundary file

bfMeshData.seek(0)
bfRef.seek(0)
bfRefText = bfRef.readlines()

for iL in range(bndDefStartLine - 1):
    bfMeshData.write(bfRefText[iL])

bfMeshData.write(str(nBnds)+'(\n')
bfMeshData.write('\n')

for boundary in bndInfo:
    bfMeshData.write('    '+boundary+'\n')
    bfMeshData.write('    {\n')
    bfMeshData.write('        nFaces ' + str(bndInfo[boundary]['nFaces']) + ';\n')
    bfMeshData.write('        startFace ' + str(bndInfo[boundary]['startFace']) + ';\n')
    bfMeshData.write('        type ' + bndInfo[boundary]['type'] + ';\n')
    bfMeshData.write('    }\n')
    bfMeshData.write('\n')
bfMeshData.write(')\n')


bfMeshData.truncate()
bfMeshData.close()
bfRef.close()



