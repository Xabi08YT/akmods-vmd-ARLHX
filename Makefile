_SRC := $(if $(src),$(src),.)
include $(_SRC)/Makefile.vars # AKMOD can be annoying so preventing his silent context change

KERNELRELEASE := $(shell uname -r)

KMOD_DIR        := /lib/modules/$(KERNELRELEASE)/extra

ccflags-y := -std=gnu11 -Wno-declaration-after-statement

obj-m += $(MODNAME).o

all: modules

modules:
	@$(MAKE) -C /lib/modules/$(KERNELRELEASE)/build M=$(CURDIR) modules

clean:
	@$(MAKE) -C /lib/modules/$(KERNELRELEASE)/build M=$(CURDIR) clean

load:
	insmod vmd.ko

unload:
	-rmmod vmd

reload: unload load

install:
	mkdir -p $(KMOD_DIR)
	cp vmd.ko $(KMOD_DIR)
	depmod -a
	echo vmd > /etc/modules-load.d/vmd.conf
	modprobe -v vmd

uninstall:
	-modprobe -rv vmd
	rm -f $(KMOD_DIR)/vmd.ko
	-rmdir -p $(KMOD_DIR) > /dev/null 2>&1
	depmod -a
	rm -f /etc/modules-load.d/vmd.conf

dev: modules unload load

rpm:
	$(MAKE) -C packaging/rpm-akmod/ srpm