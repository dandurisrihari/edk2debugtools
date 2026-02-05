#!/usr/bin/env make

SHELL=/bin/bash

LOG=debug.log
OVMFBASE=../Build/OvmfX64/DEBUG_GCC5/
OVMFCODE=$(OVMFBASE)/FV/OVMF_CODE.fd
OVMFVARS=$(OVMFBASE)/FV/OVMF_VARS.fd
QEMU=qemu-system-x86_64
QEMUFLAGS=-m 2048 \
        -drive format=raw,file=fat:rw:shared \
        -drive if=pflash,format=raw,readonly,file=$(OVMFCODE) \
        -drive if=pflash,format=raw,file=$(OVMFVARS) \
        -debugcon file:$(LOG) -global isa-debugcon.iobase=0x402 \
        -fw_cfg name=opt/org.tianocore/X-Cpuhp-Bugcheck-Override,string=yes \
        -device virtio-vga \
        -vnc :0

run:
	@pkill -9 qemu-system-x86 2>/dev/null || true
	$(QEMU) $(QEMUFLAGS)

debug:
	@pkill -9 qemu-system-x86 2>/dev/null || true
	$(QEMU) $(QEMUFLAGS) -s -S


.PHONY: run debug