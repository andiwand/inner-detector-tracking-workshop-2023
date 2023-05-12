#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}"  )" &> /dev/null && pwd  )

set -u
set -e

function download() {
  set -e

  curl \
    --location \
    --create-dirs $1 \
    | tar -xz --strip-components=1 --directory $2
}


BUILD_DIR=$1
PREFIX=$2

mkdir -p $PREFIX
mkdir -p $BUILD_DIR
PREFIX=$(realpath $PREFIX)


function group {
    let n=${#1}-1
    s=$(printf "=%${n}s" | tr " " "=")
    echo ""
    echo $s
    echo "${@}"
    echo $s
    echo ""
}

cd $BUILD_DIR

GEANT4_VERSION=11.1.1
HEPMC3_VERSION=3.2.5
PYTHIA8_VERSION=309
JSON_VERSION=3.11.2
ROOT_VERSION=6.28.02
PODIO_VERSION=00-16-03
EDM4HEP_VERSION=00-07-02
DD4HEP_VERSION=01-25-01

group Versions
echo "GEANT4_VERSION:  $GEANT4_VERSION"
echo "HEPMC3_VERSION:  $HEPMC3_VERSION"
echo "PYTHIA8_VERSION: $PYTHIA8_VERSION"
echo "JSON_VERSION:    $JSON_VERSION"
echo "ROOT_VERSION:    $ROOT_VERSION"
echo "PODIO_VERSION:   $PODIO_VERSION"
echo "EDM4HEP_VERSION: $EDM4HEP_VERSION"
echo "DD4HEP_VERSION:  $DD4HEP_VERSION"

# apt-get install -y \
  # build-essential \
  # curl \
  # git \
  # freeglut3-dev \
  # libboost-dev \
  # libboost-filesystem-dev \
  # libboost-program-options-dev \
  # libboost-test-dev \
  # libeigen3-dev \
  # libexpat-dev \
  # libftgl-dev \
  # libgl2ps-dev \
  # libglew-dev \
  # libgsl-dev \
  # liblz4-dev \
  # liblzma-dev \
  # libpcre3-dev \
  # libtbb-dev \
  # libx11-dev \
  # libxext-dev \
  # libxft-dev \
  # libxpm-dev \
  # libxerces-c-dev \
  # libxxhash-dev \
  # libzstd-dev \
  # ninja-build \
  # python3 \
  # python3-dev \
  # python3-pip \
  # rsync \
  # zlib1g-dev \

function build() {
  set -e

  name=$1
  version=$2
  url=$3
  cmd="$4"
  shift 4

  echo "BUILD ${name}"
  echo $name $version $url
  echo $cmd
  echo "---"

  src=${name}_src
  bld=${name}_build
  prfx=${PREFIX}/${name}/${version}
  stamp=${name}.stamp

  if [ ! -f "$stamp" ]; then
    group "Building ${name}"

    if [ -d "$src" ]; then
      rm -r $src
    fi

    mkdir $src
    download $url $src

    if [ -d "$bld" ]; then
      rm -rf "$bld"
    fi
    mkdir -p $bld

    eval "$cmd"

    date > $stamp

  fi

}

function build_cmake() {
  set -e

  name=$1
  version=$2
  url=$3
  patch=$4
  shift 4
  args="$@"

  cmd=""

  if [ ! -z "$patch" ]; then 
    cmd+='pushd $src && curl '"${patch}"' | patch -p1 && popd && '
  fi

  cmd+='cmake -B $bld -S $src'
  cmd+=" $args"
  cmd+=' && cmake --build $bld && cmake --install $bld'

  build $name $version $url "$cmd"
}

CCACHE=$(command -v ccache || true)
if [ ! -z "$CCACHE" ]; then
  echo "Using ccache: $CCACHE"
  export CMAKE_CXX_COMPILER_LAUNCHER=$CCACHE
fi

build_cmake \
  geant4 \
  $GEANT4_VERSION \
  https://gitlab.cern.ch/geant4/geant4/-/archive/v${GEANT4_VERSION}/geant4-v${GEANT4_VERSION}.tar.gz \
  "" \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=\$prfx \
  -DCMAKE_CXX_STANDARD=20 \
  -DGEANT4_BUILD_TLS_MODEL=global-dynamic \
  -DGEANT4_INSTALL_DATA=OFF \
  -DGEANT4_USE_GDML=ON \
  -DGEANT4_USE_SYSTEM_EXPAT=ON \
  -DGEANT4_USE_SYSTEM_ZLIB=ON

export CMAKE_PREFIX_PATH="$PREFIX/geant4/$GEANT4_VERSION"

build_cmake \
  hepmc3 \
  $HEPMC3_VERSION \
  https://hepmc.web.cern.ch/hepmc/releases/HepMC3-${HEPMC3_VERSION}.tar.gz \
  "" \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=\$prfx \
  -DHEPMC3_BUILD_STATIC_LIBS=OFF \
  -DHEPMC3_ENABLE_PYTHON=OFF \
  -DHEPMC3_ENABLE_ROOTIO=OFF \
  -DHEPMC3_ENABLE_SEARCH=OFF

build \
  pythia8 \
  $PYTHIA8_VERSION \
  https://pythia.org/download/pythia83/pythia8${PYTHIA8_VERSION}.tgz \
  "pushd \$src && ./configure --enable-shared --prefix=\$prfx && make -j$(nproc) install && popd"

build_cmake \
  json \
  $JSON_VERSION \
  https://github.com/nlohmann/json/archive/refs/tags/v${JSON_VERSION}.tar.gz \
  "" \
  -GNinja -DJSON_BuildTests=OFF -DCMAKE_INSTALL_PREFIX=\$prfx

export CMAKE_PREFIX_PATH+=":$PREFIX/json/$JSON_VERSION"

build_cmake \
  root \
  $ROOT_VERSION \
  https://root.cern/download/root_v${ROOT_VERSION}.source.tar.gz \
  "" \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_INSTALL_PREFIX=\$prfx \
  -Dfail-on-missing=ON \
  -Dgdml=ON \
  -Dx11=ON \
  -Dpyroot=ON \
  -Ddataframe=ON \
  -Dmysql=OFF \
  -Doracle=OFF \
  -Dpgsql=OFF \
  -Dsqlite=OFF \
  -Dpythia6=OFF \
  -Dpythia8=OFF \
  -Dfftw3=OFF \
  -Dbuiltin_cfitsio=ON \
  -Dbuiltin_xxhash=ON \
  -Dbuiltin_afterimage=ON \
  -Dbuiltin_openssl=ON \
  -Dbuiltin_ftgl=ON \
  -Dgfal=OFF \
  -Ddavix=OFF \
  -Dbuiltin_vdt=ON \
  -Dxrootd=OFF \
  -Dtmva=OFF


export CMAKE_PREFIX_PATH+=":$PREFIX/root/$ROOT_VERSION"

build_cmake \
  podio \
  $PODIO_VERSION \
  https://github.com/AIDASoft/podio/archive/refs/tags/v${PODIO_VERSION}.tar.gz \
  "https://github.com/AIDASoft/podio/commit/09d17d49f434e23663137eadacfea4eaa3d58d48.patch" \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_INSTALL_PREFIX=\$prfx \
  -DBUILD_TESTING=OFF \
  -USE_EXTERNAL_CATCH2=OFF \

python3 -m venv $PWD/venv
source $PWD/venv/bin/activate
pip install jinja2 pyyaml

export CMAKE_PREFIX_PATH+=":$PREFIX/podio/$PODIO_VERSION"

build_cmake \
  edm4hep \
  $EDM4HEP_VERSION \
  https://github.com/key4hep/EDM4hep/archive/refs/tags/v${EDM4HEP_VERSION}.tar.gz \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=\$prfx \
  -DBUILD_TESTING=OFF \
  -DUSE_EXTERNAL_CATCH2=OFF \
  '&& pushd $src && curl https://patch-diff.githubusercontent.com/raw/key4hep/EDM4hep/pull/201.patch | patch -p1 && popd'

export CMAKE_PREFIX_PATH+=":$PREFIX/edm4hep/$EDM4HEP_VERSION"

echo $CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH="$PREFIX/geant4/$GEANT4_VERSION/lib"
source $PREFIX/root/$ROOT_VERSION/bin/thisroot.sh

build_cmake \
  dd4hep \
  $DD4HEP_VERSION \
  https://github.com/AIDASoft/DD4hep/archive/v${DD4HEP_VERSION}.tar.gz \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=20 \
  -DCMAKE_INSTALL_PREFIX=\$prfx \
  -DBUILD_TESTING=OFF \
  '-DDD4HEP_BUILD_PACKAGES="DDG4 DDDetectors DDRec UtilityApps"' \
  -DDD4HEP_USE_GEANT4=ON \
  -DDD4HEP_USE_XERCESC=ON \
  -DDD4HEP_USE_EDM4HEP=ON \
