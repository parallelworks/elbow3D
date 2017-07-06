A Swift workflow for running flow in a 3D Elbow geometry.

Usage
-----

### Running the workflow locally without dockers

-   To run locally without dockers Paraview, openFoam and Salome are required. Make sure the installation paths in `swift.conf_local` file are set correctly.
-   Run the swift workflow:

    ``` example
    swift -config swift.conf_local  mainElbow3D.swift
    ```

### Running the workflow locally with embedded dockers

-   Run the swift workflow with swift.conf\_local\_explicitDockers

    ``` example
    swift -config swift.conf_local_explicitDockers  mainElbow3D.swift
    ```

Geometry
--------

The geometric parameters are specified in `inputs/sweepParams.run`. The parameters are shown below:

![3D Elbow geometry](README_files/elbow3D_geom.png)

Metric Extraction
-----------------

Metric extraction is specified in `inputs/elbowKPI.json`. For documentation of metric extraction see <https://github.com/parallelworks/MetricExtraction>
