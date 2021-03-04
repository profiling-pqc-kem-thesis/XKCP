MAKEFLAGS += --silent

export CCFLAGS := $(CCFLAGS) -O3 -Wall -Wextra -pedantic -Wno-unused-parameter -march=native -fno-omit-frame-pointer -g

# -------------- library --------------
header_directories := lib/common/ lib/high/Keccak/ lib/high/Keccak/FIPS202/ lib/low/common/ lib/low/KeccakP-1600/common/ lib/low/KeccakP-1600/$(TARGET)/
ifdef SUB_TARGET
header_directories += lib/low/KeccakP-1600/$(TARGET)/$(SUB_TARGET)/
endif
headers := $(foreach header_directory, $(header_directories), $(shell ls -d $(header_directory)* | grep "\.h"))
header_directories := $(addprefix -I , $(header_directories))

source_c := $(shell find lib/common lib/high lib/low/common lib/low/KeccakP-1600/$(TARGET) -type f -name "*.c")
source_s := $(shell find lib/common lib/high lib/low/common lib/low/KeccakP-1600/$(TARGET) -type f -name "*.s")

objects_c := $(addprefix build/, $(source_c:.c=.o))
objects_s := $(addprefix build/, $(source_s:.s=.o))

implementations := $(shell find build/* -maxdepth 0 -type d 2>/dev/null | grep -v "build/lib")

# -------------- tests --------------
test_headers := $(shell find tests/UnitTests/ -type f -name "*.h")
test_source := $(shell find tests/UnitTests/ -type f -name "*.c")


.PHONY: library clean main test

main: main.c
	$(foreach implementation, $(implementations), $(shell $(CC) $(CCFLAGS) -o $(implementation)/main.out main.c -I $(implementation)/keccak/libkeccak.a.headers -L $(implementation)/keccak -lkeccak))

plain-64bits/lcu6:
	TARGET="plain-64bits" SUB_TARGET="lcu6" $(MAKE) library

plain-64bits/lcua:
	TARGET="plain-64bits" SUB_TARGET="lcua" $(MAKE) library

plain-64bits/lcua-shld:
	TARGET="plain-64bits" SUB_TARGET="lcua-shld" $(MAKE) library

plain-64bits/u6:
	TARGET="plain-64bits" SUB_TARGET="u6" $(MAKE) library

plain-64bits/ua:
	TARGET="plain-64bits" SUB_TARGET="ua" $(MAKE) library

ref-64bits:
	TARGET="ref-64bits" $(MAKE) library

compact:
	TARGET="compact" $(MAKE) library

AVX2:
	TARGET="AVX2" $(MAKE) library

AVX512:
	TARGET="AVX512" $(MAKE) library

AVX512-C/u6:
	TARGET="AVX512/C" SUB_TARGET="u6" $(MAKE) library

AVX512-C/u12:
	TARGET="AVX512/C" SUB_TARGET="u12" $(MAKE) library

AVX512-C/ua:
	TARGET="AVX512/C" SUB_TARGET="ua" $(MAKE) library

XOP/u6:
	TARGET="XOP" SUB_TARGET="u6" $(MAKE) library

XOP/ua:
	TARGET="XOP" SUB_TARGET="ua" $(MAKE) library

library: build/$(TARGET)$(SUB_TARGET)/keccak/libkeccak.a $(headers)
	mkdir -p build/$(TARGET)$(SUB_TARGET)/keccak/libkeccak.a.headers
	cp $(headers) build/$(TARGET)$(SUB_TARGET)/keccak/libkeccak.a.headers/
	rm -rf build/lib &> /dev/null || true

build/$(TARGET)$(SUB_TARGET)/keccak/libkeccak.a: $(objects_c) $(objects_s)
	mkdir -p $(dir $@)
ifeq ($(shell uname),Darwin)
	libtool -static -o $@ $(objects_c) $(objects_s)
else
	$(AR) rcs $@ $(objects_c) $(objects_s)
endif

$(objects_c): build/%.o: %.c $(headers)
	mkdir -p $(dir $@)
	$(CC) $(CCFLAGS) -c -o $@ $< $(header_directories)

$(objects_s): build/%.o: %.s $(headers)
	mkdir -p $(dir $@)
	$(CC) $(CCFLAGS) -c -o $@ $< $(header_directories)

test: $(test_source) $(test_headers)
	$(foreach implementation, $(implementations), $(shell $(CC) $(CCFLAGS) -o $(implementation)/test.out $(test_source) -I $(implementation)/keccak/libkeccak.a.headers -L $(implementation)/keccak -lkeccak))

clean:
	rm -rf build/ ShortMsgKAT_SHA3-224.txt ShortMsgKAT_SHA3-256.txt ShortMsgKAT_SHA3-384.txt ShortMsgKAT_SHA3-512.txt ShortMsgKAT_SHAKE128.txt ShortMsgKAT_SHAKE256.txt &> /dev/null || true
