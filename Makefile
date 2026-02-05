#!/usr/bin/env make

SHELL=/bin/bash

LOG=debug.log
OVMFBASE=../Build/OvmfX64/DEBUG_GCC5/
OVMFCODE=$(OVMFBASE)/FV/OVMF_CODE.fd
OVMFVARS=$(OVMFBASE)/FV/OVMF_VARS.fd
QEMU=qemu-system-x86_64
# Use virtio-net without ROM - OVMF's VirtioNetDxe will handle it
# Enable all network options: IPv4, IPv6, HTTP boot
# Add virtio-rng for EFI_RNG_PROTOCOL required by network stack
QEMUFLAGS=-m 2048 \
        -drive format=raw,file=fat:rw:shared \
        -drive if=pflash,format=raw,readonly=on,file=$(OVMFCODE) \
        -drive if=pflash,format=raw,file=$(OVMFVARS) \
        -debugcon file:$(LOG) -global isa-debugcon.iobase=0x402 \
        -fw_cfg name=opt/org.tianocore/X-Cpuhp-Bugcheck-Override,string=yes \
        -fw_cfg name=opt/org.tianocore/IPv4Support,string=enabled \
        -fw_cfg name=opt/org.tianocore/IPv6Support,string=enabled \
        -fw_cfg name=opt/org.tianocore/HttpBootSupport,string=enabled \
        -device virtio-vga \
        -device virtio-rng-pci \
        -netdev user,id=net0,tftp=shared,bootfile=/pxelinux.0 \
        -device virtio-net-pci,netdev=net0,romfile="" \
        -vnc :0

run:
	@pkill -9 qemu-system-x86 2>/dev/null || true
	$(QEMU) $(QEMUFLAGS)

debug:
	@pkill -9 qemu-system-x86 2>/dev/null || true
	$(QEMU) $(QEMUFLAGS) -s -S


.PHONY: run debug