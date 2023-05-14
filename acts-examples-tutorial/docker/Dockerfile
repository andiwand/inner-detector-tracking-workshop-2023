FROM ghcr.io/acts-project/ubuntu2204:v41

COPY profile /root/.profile

RUN apt-get update && apt-get install -y git-lfs wget vim

RUN mkdir acts-src \
  && git clone https://github.com/acts-project/acts.git acts-src \
  && cd acts-src && git checkout v25.0.1 && git submodule update --init && cd .. \
  && cmake -B acts-build -S acts-src \
     -GNinja \
     -DCMAKE_BUILD_TYPE=RelWithDebInfo \
     -DCMAKE_CXX_STANDARD=17 \
     -DCMAKE_INSTALL_PREFIX="acts-install" \
     -DACTS_BUILD_EVERYTHING=ON \
     -DACTS_BUILD_ODD=ON \
     -DACTS_BUILD_EXAMPLES_PYTHON_BINDINGS=ON \
     -DACTS_FORCE_ASSERTIONS=ON \
     -DACTS_ENABLE_LOG_FAILURE_THRESHOLD=ON \
  && cmake --build acts-build --target install
