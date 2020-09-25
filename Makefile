PROJECT := $(shell basename $(shell pwd))
EABI=arm-none-eabi
AS=$(EABI)-as
LD=$(EABI)-ld
OBJCOPY=$(EABI)-objcopy
CC=$(EABI)-gcc
NM=$(EABI)-nm

LIB_BIP_PATH=../libbip
LIB_BIP=$(LIB_BIP_PATH)/libbip.a

CFLAGS=-mcpu=cortex-m4 -mfpu=fpv4-sp-d16 -mfloat-abi=hard -fno-math-errno -I $(LIB_BIP_PATH) -c -Os -Wa,-R -Wall -fpie -pie -fpic -mthumb -mlittle-endian  -ffunction-sections -fdata-sections
LDFLAGS=-lm -lc -EL -N -Os --cref -pie --gc-sections --no-dynamic-linker

SOURCES=$(wildcard *.c)
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=$(PROJECT).elf
MAPFILE=$(PROJECT).map

all: $(SOURCES) $(EXECUTABLE)
	
$(EXECUTABLE): $(OBJECTS) 
	$(LD) $(LDFLAGS) $(OBJECTS) $(LIB_BIP) -Map $(MAPFILE) -o $@
	if $(SHELL) -c 'test -e label.txt'; \
	    then \
		$(OBJCOPY) $@ --add-section .elf.label=label.txt; \
	    else true; fi
	echo -n "$(PROJECT)" > name.txt
	$(OBJCOPY) $@ --add-section .elf.name=name.txt
	rm -rf name.txt
	if $(SHELL) -c 'test -e asset.res'; \
	    then \
		$(OBJCOPY) $@ --add-section .elf.resources=asset.res; \
	    else true; fi
	if $(SHELL) -c 'test -e settings.bin'; \
	    then \
		$(OBJCOPY) $@ --add-section .elf.resources=settings.bin; \
	    else true; fi

.c.o:
	$(CC) $(CFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf *.o $(EXECUTABLE) $(MAPFILE)
