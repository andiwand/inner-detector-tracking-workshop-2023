# Acts Examples Framework Tutorial

## Dependencies

Biggest problem is getting the dependencies of the Acts examples framework.

## Setup variants

### lxplus+cvmfs+lcg

One way of avoiding the dependency problem is going to standard environment and use pre-compiled versions.

Acts 25.0.1 can be built against lcg103 on lxplus.

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

cmake --build acts-build -- install
```

### Docker

I have created a pre-cloned and pre-compiled Acts docker image based on an image with the pre-compiled dependencies we use in our CI `ghcr.io/acts-project/ubuntu2204:v41`.

You can find the Dockerfile [here](docker/Dockerfile).

```
docker pull ghcr.io/andiwand/acts-examples:edge

docker run -ti ghcr.io/andiwand/acts-examples:edge
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

Afterward the setup you should be able to run the full chain example.

```
Examples/Scripts/Python/full_chain_odd.py
```

(path is relative to the cloned acts source directory)

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
