# notes

NOTE: 2022-09-26 work-in-progress

CONTENTS

- [notes](#notes)
  - [Algorithms](#algorithms)
  - [Extract from containers](#extract-from-containers)
    - [Algorithm](#algorithm)
    - [Pros](#pros)
    - [Cons](#cons)
    - [Comments](#comments)
  - [Build, then new image](#build-then-new-image)
    - [Algorithm](#algorithm-1)
    - [Pros](#pros-1)
    - [Cons](#cons-1)
    - [Comments](#comments-1)

## Algorithms

1. Extract IOCs from docker containers for `conda-build`
2. Build IOCs for `conda-build`, then add to new docker images

## Extract from containers

1. Start docker IOCs
2. Create scripts to mine the containers for content
3. Store in custom directories
4. Create entry-point scripts as described
5. Build `conda` package

### Algorithm

Using existing containers (started from [docker
images](https://hub.docker.com/u/prjemian)), extract the content necesary to
configure and run each IOC, including the screens and scripts to start the
screen GUIs.  Build that content into a `conda` package using
[`conda-build`](https://docs.conda.io/projects/conda-build). Include new scripts
as entry points to start custom-named IOCs. Include a command to start the IOC
fresh (wipe the save/restore history).

### Pros

- Images already built and tested

### Cons

- Cannot run docker at APS
- Highly dependent on each docker image version
- Directories (bin, lib, dbd, ...) are non-standard

### Comments

This is becoming tedious.  Many decisions must be made based on the content and
structure of the containers.  Access to the structure of the content becomes
needlessly complicated (additional bash scripting via `sed` is necessary to
convert EOL characters received by `docker exec`, for example).  Environment
variables are not accessible directly.

This method will be slow to show progress.  Also slow to update.

## Build, then new image

1. Create conda environment for EPICS
   1. use existing `epics-base -c conda-forge` and other packages to build
   2. May need compiler tools, also
   3. Test entire process in a linux docker container (ubuntu, rocky, ...)
2. Download and build synApps for out-of-source
3. Download and build AreaDetector for out-of-source
4. Create custom versions (same as existing docker containers)
5. Create entry-point scripts as described
6. Build `conda` package
7. Build `docker` image

### Algorithm

Build all IOCs, out of source, into a `conda` package, including the content
necesary to configure and run each IOC, including the screens and scripts to
start the screen GUIs. Include new scripts as entry points to start custom-named
IOCs. Include a command to start the IOC fresh (wipe the save/restore history).
Build a single docker image that provides EPICS in conda environments.  Include
the custom IOC support in the image.

Start with [`mambaorg/micromamba`](https://hub.docker.com/r/mambaorg/micromamba) docker image?

### Pros

- Keep up with (upstream) EPICS/synApps/AreaDetector versions
- Step-wise construction of components
- Easier to update docker images

### Cons

- Must learn how to IOC build out-of-source
- Needs testing after each major step

### Comments

- Start with `mambaorg/micromamba` docker image and add packages via `env.yml`
  file.  Fantastically easy to configure and use!
  EXCEPT: No `sudo` executable, no root password, need to install some system packages.

- Start with `ubuntu:latest` docker image and build as before.  Just don't
  publish but use it to create a conda package.
