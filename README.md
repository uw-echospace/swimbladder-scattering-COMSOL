# Acoustic Scattering Models of Underwater Objects

This repository contains the analysis scripts and model files for the **Fish scattering project**, which aims to characterize the acoustic scattering functions of underwater objects, with a particular focus on realistic fish geometries.

## Project overview

### 1. Analytical benchmark models

MATLAB implementations of analytical models developed by Dezhang Chu are used to predict the scattering functions of simple spherical geometries.

### 2. COMSOL benchmark models

COMSOL models reproduce the geometries and acoustic conditions used in the analytical MATLAB models. Agreement between the analytical and COMSOL predictions is used to validate the numerical modeling framework before it is applied to more complex geometries.

### 3. Anatomically realistic fish models

The repository includes files and scripts associated with COMSOL models of:

* Rockfish specimens scanned in Taiwan
* Plainfin midshipman swimbladder geometry provided by Sujay Balebail

For the rockfish models, bone material properties are assigned using a voxel-based workflow. Bone-segment coordinates are exported from 3D Slicer and mapped onto the fish body geometry using nearest-neighbor interpolation.

## Large data files

Large files are not tracked in this GitHub repository. These include:

* CT datasets
* COMSOL `.mph` model files

These files are stored in the `vchhaya` project directory on the Pittsburgh Supercomputing Center system:

```text
/ocean/projects/bio240005p/vchhaya/
```
