# EDK2 Debug Tools

This directory contains debugging tools and utilities for EDK2 development.

## Setup Instructions

1. **Create shared directory (if not present):**
   ```bash
   mkdir -p shared
   ```

2. **Build peinfo tool:**
   ```bash
   cd peinfo
   make
   cd ..
   ```

3. **Build OVMF (Open Virtual Machine Firmware):**
   ```bash
   # Make sure EDK2 environment is set up first
   source ../edk2/edksetup.sh
   
   # Build OVMF package
   build -p OvmfPkg/OvmfPkgX64.dsc -b DEBUG -a X64 -t GCC5
   ```

## Running and Debugging

4. **Run OVMF in QEMU:**
   ```bash
   # Launch OVMF in QEMU and boot to UEFI shell to generate debug.log
   make run
   ```

5. **Generate debug symbols:**
   ```bash
   # Extract debug info from debug.log
   ./gen_symbol_offsets.sh > gdbscript
   ```

6. **Debug OVMF with GDB:**
   ```bash
   # Launch OVMF in debug mode (in one terminal)
   make debug
   ```
   
   ```bash
   # In another terminal, launch GDB
   gdb
   target remote :1234
   source gdbscript
   ```