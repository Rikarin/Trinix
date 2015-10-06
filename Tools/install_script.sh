yum -y update
yum -y groupinstall "Development tools"
yum -y install cmake libconfig-devel

#Build LLVM
git clone --recursive https://github.com/llvm-mirror/llvm.git

cd llvm/tools
git clone https://github.com/llvm-mirror/clang.git

cd ../projects
git clone https://github.com/llvm-mirror/compiler-rt.git

cd ../../
mkdir build && cd build
../llvm/configure --enable-optimized -prefix=/llvm
make -j 4
make install

cd ../


#Build LDC
git clone --recursive https://github.com/ldc-developers/ldc.git
git checkout release-0.16.0

#TODO: patch druntime add `-relocation-model=pic` to /cc/ldc/runtime/CMake... D_FLAGS
# a proxy.d
#netreba bo pouzivam uz predkompilovanu libku

#libcurl-devel python-devel ncurses-devel

cd ldc
mkdir build && cd build
cmake -DLLVM_ROOT_DIR=/llvm/ -DCMAKE_INSTALL_PREFIX=/llvm/ ..
make -j 4
make install