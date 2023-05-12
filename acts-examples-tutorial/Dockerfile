FROM ghcr.io/acts-project/ubuntu2204:v41

RUN apt-get update && apt-get install -y git-lfs

RUN mkdir src \
  && git clone https://github.com/acts-project/acts.git src \
  && cd src && git checkout v25.0.1 && git submodule update --init && cd .. \
  && cmake -B build -S src \
     -GNinja \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_CXX_FLAGS=-Werror \
     -DCMAKE_CXX_STANDARD=17 \
     -DCMAKE_INSTALL_PREFIX="install" \
     -DACTS_ENABLE_LOG_FAILURE_THRESHOLD=ON \
     -DACTS_BUILD_EVERYTHING=ON \
     -DACTS_BUILD_ODD=ON \
     -DACTS_BUILD_EXAMPLES_PYTHON_BINDINGS=ON \
     -DACTS_FORCE_ASSERTIONS=ON \
     -DACTS_BUILD_ANALYSIS_APPS=ON \
     -DACTS_BUILD_PLUGIN_ONNX=ON \
  && cmake --build build -- install
