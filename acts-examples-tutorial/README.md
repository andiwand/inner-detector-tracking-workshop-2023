# Acts Examples Framework Tutorial

The goal of this tutorial is to build Acts and the examples framework in order to run [`tutorial_full_chain_odd.py`](tutorial_full_chain_odd.py) and to plug a dummy algorithm into the reconstruction chain.

## Dependencies

Biggest problem is getting the dependencies of the Acts examples framework.

You will need at least

- Boost
- Eigen
- Root
- Geant4
- DD4hep

## Setup

### lxplus+cvmfs+lcg

One way of avoiding the dependency problem is going to standard environment and use pre-compiled versions.

Acts 25.0.1 can be built against lcg 103 on lxplus.

```
source /cvmfs/sft.cern.ch/lcg/views/LCG_103/x86_64-centos7-gcc11-opt/setup.sh

git clone https://github.com/acts-project/acts.git acts-src

cd acts-src
git checkout v25.0.1
git submodule update --init
cd ..

cmake -B acts-build -S acts-src \
  -GNinja \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_CXX_STANDARD=17 \
  -DCMAKE_INSTALL_PREFIX="acts-install" \
  -DACTS_BUILD_ODD=ON \
  -DACTS_BUILD_FATRAS=ON \
  -DACTS_BUILD_FATRAS_GEANT4=ON \
  -DACTS_BUILD_EXAMPLES_DD4HEP=ON \
  -DACTS_BUILD_EXAMPLES_GEANT4=ON \
  -DACTS_BUILD_EXAMPLES_PYTHIA8=ON \
  -DACTS_BUILD_EXAMPLES_PYTHON_BINDINGS=ON \
  -DACTS_FORCE_ASSERTIONS=ON \
  -DACTS_ENABLE_LOG_FAILURE_THRESHOLD=ON

cmake --build acts-build --target install
```

### Docker

I have created a pre-cloned and pre-compiled Acts docker image based on an image with the pre-compiled dependencies we use in our CI `ghcr.io/acts-project/ubuntu2204:v41`.

You can find the Dockerfile [here](docker/Dockerfile).

```
docker pull ghcr.io/andiwand/acts-examples:edge

docker run -ti ghcr.io/andiwand/acts-examples:edge
```

Or if you want to mount the source folder from outside the docker container

```
git clone https://github.com/acts-project/acts.git acts-src

cd acts-src
git checkout v25.0.1
git submodule update --init
cd ..

docker run -ti -v acts-src:/acts-src ghcr.io/andiwand/acts-examples:edge
```

### local+cvmfs+lcg

This is very similar to [lxplus+cvmfs+lcg](#lxplus+cvmfs+lcg) but avoids working fully remote. Using `setupATLAS -c centos7` we create an environment like on lxplus. You will also need to have [cvmfs](https://cvmfs.readthedocs.io/en/stable/cpt-quickstart.html).

Otherwise the setup is the same as seen above.

### local

The sad truth is that the best developer experience will be achieved with a local setup on a decent machine (and OS). This means that you have to get the dependencies by yourself and that you have to compile some of them by yourself.

Boost and Eigen should be somehow available on a decent OS.

Pre-compiled [Root](https://root.cern/install/) and [Geant4](https://geant4.web.cern.ch/download/) might be available for your OS.

[DD4hep](https://dd4hep.web.cern.ch/dd4hep/page/installation/) has to be compiled.

Tipp: Use `CMAKE_INSTALL_PREFIX` to install and `CMAKE_PREFIX_PATH` to discover packages. This way you can also easily have multiple versions of the same package and create different environments.

You can find a build script [here](local/build_script.sh) (by Paul) and step by step instructions [here](https://codimd.web.cern.ch/s/w-7j8zXm0). And a CMake script is WIP [here](https://github.com/acts-project/ci-dependencies/pull/17).

## Testing your environment

Afterward the setup you should be able to run the tutorial full chain example.

```
Examples/Scripts/Python/full_chain_odd.py
```

## Problems that might be encountered

- git lfs is not correctly set-up and ODD will not have material files
  - `git lfs install`
  - `git lfs pull`
  - `git lfs checkout`
- Acts is not correctly sourced
  - `source bin/this_acts.sh`
  - `source python/setup.sh`
- Other packages are not correctly sourced
  - see [here](docker/profile)
- `detector_types.xml` missing
  - `cd thirdparty/OpenDataDetector/xml`
  - `wget https://raw.githubusercontent.com/AIDASoft/DD4hep/master/DDDetectors/compact/detector_types.xml`
  - edit `OpenDataDetector.xml`
  - (opened a PR to fix this [here](https://gitlab.cern.ch/acts/OpenDataDetector/-/merge_requests/65))

## Adding a user specific algorithm

The best way of adding a user specific algorithm to Acts is to do it directly in the examples source tree.

We are going to add a `TutorialAlgorithm` to the chain which logs a message to the terminal on execution.

The first step is to copy the following files into the given location

- [`TutorialAlgorithm.hpp`](https://github.com/andiwand/acts/blob/tutorial-algorithm-for-idtw2023/Examples/Algorithms/TrackFinding/include/ActsExamples/TrackFinding/TutorialAlgorithm.hpp) -> `Examples/Algorithms/TrackFinding/include/ActsExamples/TrackFinding/TutorialAlogrithm.hpp`
- [`TutorialAlgorithm.cpp`](https://github.com/andiwand/acts/blob/tutorial-algorithm-for-idtw2023/Examples/Algorithms/TrackFinding/src/TutorialAlgorithm.cpp) -> `Examples/Algorithms/TrackFinding/src/TutorialAlogrithm.cpp`
- [`tutorial_full_chain_odd.py`](https://github.com/andiwand/acts/blob/tutorial-algorithm-for-idtw2023/Examples/Scripts/Python/tutorial_full_chain_odd.py) -> `Examples/Scripts/Python/tutorial_full_chain_odd.py`

Afterwards we have to inform CMake that there is a new source file which sould be included in the build. To do that edit `Examples/Algorithms/TrackFinding/CMakeLists.txt` and append `src/TutorialAlogrithm.cpp` to the `add_library` function as an argument.

Now we need to add a Python binding to be able to add our new algorithm to reconstruction chain. This can be done by editing `Examples/Python/src/TrackFinding.cpp`. First we need to add an include for our algorithm. Then go to the end of the file, copy-paste one of the other algorithm bindings (like the one for `AmbiguityResolutionAlgorithm`) and edit it accordingly. Afterwards it should look like this:

```
#include "ActsExamples/TrackFinding/TutorialAlgorithm.hpp"

...

  ACTS_PYTHON_DECLARE_ALGORITHM(ActsExamples::TutorialAlgorithm, mex,
                                "TutorialAlgorithm", message);
```

We are ready to recompile Acts. Do this by executing `cmake --build acts-build --target install`.

Now run the tutorial full chain again and check if the output changed.

```
idtw2023/acts-examples-tutorial/tutorial_full_chain_odd.py
```

A summary of the changes we made can be seen here https://github.com/acts-project/acts/pull/2128.

If you want to check them out locally you can do

```
git remote add tutorial https://github.com/andiwand/acts.git
git fetch --all
git checkout tutorial/tutorial-algorithm-for-idtw2023
```
