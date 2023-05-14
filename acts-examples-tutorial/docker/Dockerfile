FROM ghcr.io/acts-project/ubuntu2204:v41

RUN apt-get update && apt-get install -y git-lfs wget vim gdb

RUN useradd -ms /bin/bash acts
USER acts
WORKDIR /home/acts

RUN mkdir acts-src \
  && git clone https://github.com/acts-project/acts.git acts-src \
  && cd acts-src && git checkout v25.0.1 && git submodule update --init && cd .. \
  && cmake -B acts-build -S acts-src \
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
     -DACTS_ENABLE_LOG_FAILURE_THRESHOLD=ON \
  && cmake --build acts-build --target install

RUN echo \
  "\n\n" \
  "# acts setup\n" \
  "\n" \
  "source /usr/local/bin/thisroot.sh\n" \
  "source /usr/local/bin/geant4.sh\n" \
  "source /usr/local/bin/thisdd4hep.sh\n" \
  "\n" \
  "source /home/acts/acts-install/bin/this_acts.sh\n" \
  "source /home/acts/acts-install/bin/this_odd.sh\n" \
  "source /home/acts/acts-install/python/setup.sh\n" \
  >> .bashrc
