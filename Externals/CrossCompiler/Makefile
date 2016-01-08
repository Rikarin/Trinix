#
# Build cross compiler
#
-include ../../Makefile.cfg

PREFIX      := $(SYS_DIR)/Externals/Output
PARLEVEL    := 8
BUILD_DIR   := build-$(EXTERNAL_TARGET)

BINUTILS    := binutils_dir
LLVM        := llvm_dir
LLD         := $(LLVM)/tools/lld
CLANG       := $(LLVM)/tools/clang
COMPILER_RT := $(LLVM)/projects/compiler-rt
LIBCONFIG   := libconfig_dir
LDC2        := ldc2_dir


.PHONY: all clean binutils llvm ldc2

all: binutils llvm ldc2

clean:
	@$(RM) $(BINUTILS) $(LLVM) $(LDC2)

binutils: $(PREFIX)/bin/$(EXTERNAL_TARGET)-ld
llvm: $(PREFIX)/bin/$(EXTERNAL_TARGET)-clang
ldc2: $(PREFIX)/bin/$(EXTERNAL_TARGET)-ldc2

# Download
$(BINUTILS):
	@echo --- Downloading Binutils
	@git clone -b binutils-2_25_1 --depth 1 --single-branch git://sourceware.org/git/binutils-gdb.git $(BINUTILS)

$(LLVM):
	@echo --- Downloading LLVM
	@git clone -b release_37 --depth 1 --single-branch http://llvm.org/git/llvm.git $(LLVM)
	
$(LLD):
	@echo --- Downloading LLD
	@git clone -b release_37 --depth 1 --single-branch http://llvm.org/git/lld.git $(LLD)
	
$(CLANG):
	@echo --- Downloading CLANG
	@git clone -b release_37 --depth 1 --single-branch http://llvm.org/git/clang.git $(CLANG)
	
$(COMPILER_RT):
	@echo --- Downloading Compiler-RT
	@git clone -b release_37 --depth 1 --single-branch http://llvm.org/git/compiler-rt.git $(COMPILER_RT)
	
$(LIBCONFIG):
	@echo --- Downloading Lib config
	@git clone -b REL1_6_STABLE --depth 1 --single-branch https://github.com/hyperrealm/libconfig.git $(LIBCONFIG)
	
$(LDC2):
	@echo --- Downloading LDC2
	@git clone -b release-0.17.0 --recursive --depth 1 --single-branch https://github.com/ldc-developers/ldc.git $(LDC2)

# Configure
$(BINUTILS)/$(BUILD_DIR)/Makefile: $(BINUTILS)
	@mkdir -p $(BINUTILS)/$(BUILD_DIR)
	@cd $(BINUTILS)/$(BUILD_DIR) && ../configure --target=$(EXTERNAL_TARGET) --prefix=$(PREFIX) --disable-nls

$(LLVM)/$(BUILD_DIR)/Makefile: $(LLVM) $(LLD) $(CLANG) $(COMPILER_RT)
	@mkdir -p $(LLVM)/$(BUILD_DIR)
	@cd $(LLVM)/$(BUILD_DIR) && cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$(PREFIX) ..
#@cd $(LLVM)/$(BUILD_DIR) && CC=gcc CXX=g++ CMAKE_LEGACY_CYGWIN_WIN32=1 cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=$(PREFIX) -DCMAKE_BUILD_TYPE=Release ..

$(LIBCONFIG)/$(BUILD_DIR)/Makefile: $(LIBCONFIG)
	@mkdir -p $(LIBCONFIG)/$(BUILD_DIR)
	@cd $(LIBCONFIG)/$(BUILD_DIR) && ../configure --prefix=$(PREFIX)

$(LDC2)/$(BUILD_DIR)/Makefile: $(LDC2)
	@mkdir -p $(LDC2)/$(BUILD_DIR)
	@cd $(LDC2)/$(BUILD_DIR) && cmake -DMAKE_INCLUDE_PATH=/usr/include -DLLVM_ROOT_DIR=$(PREFIX) -DCMAKE_INSTALL_PREFIX=$(PREFIX) ..

# Make
$(PREFIX)/bin/$(EXTERNAL_TARGET)-ld: $(BINUTILS)/$(BUILD_DIR)/Makefile
	@make -C $(BINUTILS)/$(BUILD_DIR) all -j $(PARLEVEL)
	@make -C $(BINUTILS)/$(BUILD_DIR) install

$(PREFIX)/bin/$(EXTERNAL_TARGET)-clang: $(LLVM)/$(BUILD_DIR)/Makefile
	@make -C $(LLVM)/$(BUILD_DIR) -j $(PARLEVEL)
	@make -C $(LLVM)/$(BUILD_DIR) install

$(PREFIX)/lib/libconfig.a: $(LIBCONFIG)/$(BUILD_DIR)/Makefile
	@make -C $(LIBCONFIG)/$(BUILD_DIR) all -j $(PARLEVEL)
	@make -C $(LIBCONFIG)/$(BUILD_DIR) install

$(PREFIX)/bin/$(EXTERNAL_TARGET)-ldc2: $(LDC2)/$(BUILD_DIR)/Makefile
	@make -C $(LDC2)/$(BUILD_DIR) all -j $(PARLEVEL)
	@make -C $(LDC2)/$(BUILD_DIR) install
