############################################################
# Makefile setting required to comply with SDL
############################################################

# stack execution protection
LDFLAGS +=-z noexecstack

# data relocation and projection
LDFLAGS +=-z relro -z now

# stack buffer overrun detection
# Note that CentOS 7 has gcc 4.8 by default.  When we switch
# to a system with gcc 4.9 or newer this should be changed to
# CFLAGS="-fstack-protector-strong"
CFLAGS +=-fstack-protector

# Position independent execution
CFLAGS +=-fPIE -fPIC
LDFLAGS +=-pie

# fortify source
CFLAGS+=-O2 -D_FORTIFY_SOURCE=2

# format string vulnerabilities
CFLAGS+=-Wformat -Wformat-security

############################################################

CFLAGS += -Werror

CFLAGS += -g -O2 -std=c99

ifdef prefix
CFLAGS += -I$(prefix)/include
LDFLAGS += -L$(prefix)/lib -L$(prefix)/lib64
AFU_JSON_MGR = $(prefix)/bin/afu_json_mgr
else
AFU_JSON_MGR = afu_json_mgr
endif
LDFLAGS += -luuid

CFLAGS += -Wall -Wno-unknown-pragmas

ifeq ($(USE_ASE),1)
	LDFLAGS += -lopae-c-ase
	CFLAGS += -DUSE_ASE
else
	LDFLAGS += -lpthread
	LDFLAGS += -lopae-c
endif

all: part3 part4 part5 part6

afu_json_info.h: ../hw/rtl/lfsr_afu.json
	$(AFU_JSON_MGR) json-info --afu-json=$^ --c-hdr=$@

part3: part3.o manage_afu.o
	gcc $(CFLAGS) -o part3 part3.o manage_afu.o $(LDFLAGS)
part3.o: part3.c afu_json_info.h
	gcc $(CFLAGS) -c -o part3.o part3.c
part4: part4.o manage_afu.o
	gcc $(CFLAGS) -o part4 part4.o manage_afu.o $(LDFLAGS)
part4.o: part4.c afu_json_info.h
	gcc $(CFLAGS) -c -o part4.o part4.c
part5: part5.o manage_afu.o
	gcc $(CFLAGS) -o part5 part5.o manage_afu.o $(LDFLAGS)
part5.o: part5.c afu_json_info.h defines.h
	gcc $(CFLAGS) -c -o part5.o part5.c
part6: part6.o manage_afu.o
	gcc $(CFLAGS) -o part6 part6.o manage_afu.o $(LDFLAGS)
part6.o: part6.c afu_json_info.h defines.h
	gcc $(CFLAGS) -c -o part6.o part6.c

manage_afu.o: manage_afu.c afu_json_info.h
	gcc $(CFLAGS) -c -o manage_afu.o manage_afu.c

clean:
	$(RM) part3 part4 part5 part3.o part4.o part5.o manage_afu.o afu_json_info.h

.PHONY:all clean
