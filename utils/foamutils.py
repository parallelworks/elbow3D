import subprocess
import os
import re
import math
import data_IO
import sys
from collections import OrderedDict

# Need the tool surfaceCheck openFoam for this function
def getBoundingBoxFromStl(stlFileAddress):
    print(os.getcwd())
    surfOut = subprocess.check_output(["surfaceCheck", stlFileAddress, "-verbose"])
    for line in surfOut.decode("utf-8").split('\n'):
        flagStr = 'Bounding Box : '
        if line.startswith(flagStr):
            bndBoxLine = line[len(flagStr):]
            break
    bndBoxStr = re.findall("[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", bndBoxLine)
    bndBox = [float(i) for i in bndBoxStr]
    return bndBox


def calcLooseBoundingBox(tightBndBox):
    bndBox = tightBndBox
    for i in range(3):
        bndBox[i] = math.floor(bndBox[i]-1.0)
    for i in range(3,6):
        bndBox[i] = math.ceil(bndBox[i] + 1.0)
    return bndBox


def convertBoundingBox2tupleformat(bndBox):
    bndBoxTuple = []
    for i in range(3):
        bndBoxTuple.append([bndBox[i], bndBox[i+3]])
    return bndBoxTuple


# See OpenFOAM user guide
# Sec 4.3  Mesh generation with the blockMesh utility
def boundingBoxVerticesOrder():

    verticesList_xy = [[0, 0], [1, 0], [1, 1], [0, 1]]
    count = 0
    verticesList = []
    for z in range(2):
        for vertex in verticesList_xy:
            verticesList.append(vertex + [z])
            count += 1
    return verticesList


def getBoxVertices(bndBox):
    bndBox = convertBoundingBox2tupleformat(bndBox)
    verticesOrder = boundingBoxVerticesOrder()
    vertices = []
    for vertexOrder in verticesOrder:
        vertex = []
        for i, level in enumerate(vertexOrder):
            vertex.append(bndBox[i][level])
        vertices.append(vertex)
    return vertices


def getBoundaryMeshInfo(boundaryName, boundary_filePointer):

    boundary_filePointer.seek(0)
    fileText = data_IO.removeLeadSpacesFromStrList(boundary_filePointer.readlines())
    fileText = data_IO.removeTrailingCharFromStrList(fileText, ';')
    foundBoundary = False
    for line_no, line in enumerate(fileText):
        if line.strip() == boundaryName:
            foundBoundary = True
            break    # Found the boundary we were looking for
    if not foundBoundary:
        print("Error: cannot find boundary ", boundaryName, " in", boundary_filePointer.name)
        sys.exit(1)
    nFaces = data_IO.read_int_from_strList(fileText, 'nFaces', None, 0, line_no)
    startFace = data_IO.read_int_from_strList(fileText, 'startFace', None, 0, line_no)
    return nFaces, startFace


# The number of boundaries is given before the list of boundaries starts, e.g.:
#
#  FoamFile
# {
#     version     2.0;
#     format      ascii;
#     class       polyBoundaryMesh;
#     location    "constant/polyMesh";
#     object      boundary;
# }
# // * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * //
#
# 4                      <--------------- Here
# (
#     pressure-outlet
#     {
#         type            wall;
#         inGroups        1(wall);
#  .....
def getNumBoundariesFromFile(fp):
    fp.seek(0)
    fileText = data_IO.removeLeadSpacesFromStrList(fp.readlines())
    fileText = data_IO.removeTrailingCharFromStrList(fileText, ';')
    for line_no, line in enumerate(fileText):
        if line.strip().endswith('('):
            if len(line.strip().rstrip('(')) > 0:
                numBoundaries = int(line.strip().rstrip('('))
            else:
                numBoundaries = int(fileText[line_no - 1])
            bndDefStartLine = line_no + 1
            break    # Found the boundary we were looking for

    return numBoundaries, bndDefStartLine


def getBoundaryTypesFromFile(fp, bndDefStarLine ):
    fp.seek(0)
    fileText = data_IO.removeLeadSpacesFromStrList(fp.readlines())
    fileText = data_IO.removeTrailingCharFromStrList(fileText, ';')
    fileText = fileText[bndDefStarLine:]

    bndTypes = OrderedDict()
    for line_no, line in enumerate(fileText):
        if line.strip() == '{':
            bndName = fileText[line_no - 1].rstrip()
            bndTypes[bndName] = {}
            bndTypes[bndName]['type'] = data_IO.read_str_from_strList(fileText, 'type', None, 0, line_no)

    return bndTypes

