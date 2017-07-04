# -*- coding: utf-8 -*-

###
### This file is generated automatically by SALOME v8.2.0 with dump python functionality
###

import sys
import salome
import os 

### needed if loading in salome GUI
sys.path.append(os.getcwd())
import data_IO

# Input arguments: 

if len(sys.argv) < 2:
    print("Number of provided arguments: ", len(sys.argv) -1 )
    print( "Usage: python elbow3D_inputFile.py <inputFile.in>")
    print( "       [<stlOutDir=./meshExports-test/>")
    sys.exit()

inputFileName = sys.argv[1]

if len(sys.argv) > 2:
  stlOutDir  = sys.argv[2]
else:
  stlOutDir =  "meshExports-test/" 


in_fp = data_IO.open_file(inputFileName)

R = data_IO.read_float_from_file_pointer(in_fp, "R")
r = data_IO.read_float_from_file_pointer(in_fp, "r")
L1 = data_IO.read_float_from_file_pointer(in_fp, "L1")
L2 = data_IO.read_float_from_file_pointer(in_fp, "L2")
Rcurve = data_IO.read_float_from_file_pointer(in_fp, "Rcurve")
xIn2 = data_IO.read_float_from_file_pointer(in_fp, "xIn2")
yIn2 = data_IO.read_float_from_file_pointer(in_fp, "yIn2")

in_fp.close()

salome.salome_init()
theStudy = salome.myStudy

if not os.path.exists(stlOutDir):
  os.makedirs(stlOutDir)

###
### GEOM component
###

import GEOM
from salome.geom import geomBuilder
import math
import SALOMEDS


geompy = geomBuilder.New(theStudy)

O = geompy.MakeVertex(0, 0, 0)
OX = geompy.MakeVectorDXDYDZ(1, 0, 0)
OY = geompy.MakeVectorDXDYDZ(0, 1, 0)
OZ = geompy.MakeVectorDXDYDZ(0, 0, 1)
geomObj_1 = geompy.MakeMarker(0, 0, 0, 1, 0, 0, 0, 1, 0)
geomObj_2 = geompy.MakeMarker(0, 0, 0, 1, 0, 0, 0, 1, 0)
sk = geompy.Sketcher2D()
sk.addPoint(0.0000000, R)
sk.addSegmentRelative(L1, 0.0000000)
sk.addArcRadiusLength(Rcurve, 90.0000000)
sk.addSegmentRelative(0.0000000, L2)
Sketch_1 = sk.wire(geomObj_2)
Sketch_1_vertex_3 = geompy.GetSubShape(Sketch_1, [3])
Circle_1 = geompy.MakeCircle(Sketch_1_vertex_3, OX, R)
Face_1 = geompy.MakeFaceWires([Circle_1], 1)
Pipe_1 = geompy.MakePipe(Face_1, Sketch_1)
Vertex_1 = geompy.MakeVertex(xIn2, yIn2, 0)

cylinderHeight = Rcurve + R  -math.sqrt((Rcurve + R)**2 - (xIn2-L1 +r)**2) - yIn2 + R/2
Cylinder_1 = geompy.MakeCylinder(Vertex_1, OY, r, cylinderHeight)
Fuse_1 = geompy.MakeFuseList([Pipe_1, Cylinder_1], True, True)

listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["VERTEX"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["VERTEX"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
listSubShapeIDs = geompy.SubShapeAllIDs(Fuse_1, geompy.ShapeType["FACE"])
velocity_inlet_1 = geompy.CreateGroup(Fuse_1, geompy.ShapeType["FACE"])
geompy.UnionIDs(velocity_inlet_1, [3])
velocity_inlet_2 = geompy.CreateGroup(Fuse_1, geompy.ShapeType["FACE"])
geompy.UnionIDs(velocity_inlet_2, [32])
walls = geompy.CreateGroup(Fuse_1, geompy.ShapeType["FACE"])
geompy.UnionIDs(walls, [12, 7, 20, 25])
pressure_outlet = geompy.CreateGroup(Fuse_1, geompy.ShapeType["FACE"])
geompy.UnionIDs(pressure_outlet, [30])
geompy.addToStudy( O, 'O' )
geompy.addToStudy( OX, 'OX' )
geompy.addToStudy( OY, 'OY' )
geompy.addToStudy( OZ, 'OZ' )
geompy.addToStudy( Sketch_1, 'Sketch_1' )
geompy.addToStudyInFather( Sketch_1, Sketch_1_vertex_3, 'Sketch_1:vertex_3' )
geompy.addToStudy( Circle_1, 'Circle_1' )
geompy.addToStudy( Face_1, 'Face_1' )
geompy.addToStudy( Pipe_1, 'Pipe_1' )
geompy.addToStudy( Vertex_1, 'Vertex_1' )
geompy.addToStudy( Cylinder_1, 'Cylinder_1' )
geompy.addToStudy( Fuse_1, 'Fuse_1' )
geompy.addToStudyInFather( Fuse_1, velocity_inlet_1, 'velocity-inlet-1' )
geompy.addToStudyInFather( Fuse_1, velocity_inlet_2, 'velocity-inlet-2' )
geompy.addToStudyInFather( Fuse_1, walls, 'walls' )
geompy.addToStudyInFather( Fuse_1, pressure_outlet, 'pressure-outlet' )

geompy.ExportSTL(velocity_inlet_1, stlOutDir+"/velocity-inlet-1.stl", True, 0.001, True)
geompy.ExportSTL(velocity_inlet_2, stlOutDir + "/velocity-inlet-2.stl", True, 0.001, True)
geompy.ExportSTL(walls, stlOutDir + "/walls.stl", True, 0.001, True)
geompy.ExportSTL(pressure_outlet, stlOutDir + "/pressure-outlet.stl", True, 0.001, True)

if salome.sg.hasDesktop():
  salome.sg.updateObjBrowser(True)
