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
   # Launch OVMF in QEMU (VNC on localhost:5900)
   make run
   
   # Connect via VNC viewer
   vncviewer localhost:5900
   ```

5. **Generate debug symbols:**
   ```bash
   # Extract debug info from debug.log
   ./gen_symbol_offsets.sh > gdbscript
   ```

6. **Debug OVMF with GDB:**
   ```bash
   # Terminal 1: Launch OVMF in debug mode (VNC: localhost:5900, GDB: localhost:1234)
   make debug
   
   # Terminal 2: Connect VNC viewer
   vncviewer localhost:5900
   
   # Terminal 3: Launch GDB and connect
   gdb
   target remote :1234
   source gdbscript
   ```