import foamutils
import sys
import data_IO

# Input arguments:

if len(sys.argv) < 3:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeBlockMeshDictFile.py <stlFileAddress> <blockMeshDictPath>")
    sys.exit()

stlFileAddress = sys.argv[1]
blockMeshFilePath = sys.argv[2]


tightBndBox = foamutils.getBoundingBoxFromStl(stlFileAddress)

bndBox = foamutils.calcLooseBoundingBox(tightBndBox)

vertices = foamutils.getBoxVertices(bndBox)

blockMeshFile = data_IO.open_file(blockMeshFilePath+'/blockMeshDict', "w")

blockMeshFile.write("FoamFile  \n"
                    "{  \n"
                    "    version 2.0;  \n"
                    "    format ascii;  \n"
                    "    class dictionary;  \n"
                    "    location system;  \n"
                    "    object blockMeshDict;  \n"
                    "}  \n"
                    "  \n"
                    "    convertToMeters 1;  \n"
                    "    vertices    \n"
                    "    (  \n" )
for vertex in vertices:
    blockMeshFile.write("     ({} {} {}) \n".format(float(vertex[0]),float(vertex[1]), float(vertex[2])))

blockMeshFile.write("    );  \n"
                    "    blocks    \n"
                    "    ( hex  \n"
                    "      ( 0 1 2 3 4 5 6 7)  \n")
blockMeshFile.write("      ( {} {} {}) simpleGrading  \n".format(
    bndBox[3]-bndBox[0], bndBox[4]-bndBox[1], bndBox[5]-bndBox[2]))

blockMeshFile.write("      ( 1 1 1)  \n"
                    "    );  \n"
                    "    edges    \n"
                    "    (  \n"
                    "    );  \n"
                    "    patches    \n"
                    "    ( wall ffminx  \n"
                    "      (  \n"
                    "      ( 0 4 7 3)) wall ffmaxx  \n"
                    "      (  \n"
                    "      ( 1 2 6 5)) wall ffminy  \n"
                    "      (  \n"
                    "      ( 0 1 5 4)) wall ffmaxy  \n"
                    "      (  \n"
                    "      ( 3 7 6 2)) wall ffminz  \n"
                    "      (  \n"
                    "      ( 0 3 2 1)) wall ffmaxz  \n"
                    "      (  \n"
                    "      ( 4 5 6 7))  \n"
                    "    );  \n"
                    "    mergePatchPairs    \n"
                    "    (  \n"
                    "    );  \n"
                    "    spacing 1.0;  \n")
blockMeshFile.close()
