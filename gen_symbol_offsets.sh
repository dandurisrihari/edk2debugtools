#!/bin/bash

LOG="debug.log"
BUILD="../edk2/Build"
SEARCHPATHS="../edk2/Build/OvmfX64/DEBUG_GCC5/X64/"
PEINFO="peinfo/peinfo"

cat "${LOG}" | grep Loading | grep -i efi | while read -r LINE; do
  BASE=$(echo "${LINE}" | awk '{print $4}')
  NAME=$(echo "${LINE}" | awk '{print $6}' | tr -d "[:cntrl:]")

  # Try exact match first
  EFIFILE=$(find "${SEARCHPATHS}" -maxdepth 1 -type f -name "${NAME}" 2>/dev/null)
  
  # If exact match fails, try pattern matching for GUID-based names
  if [[ -z "${EFIFILE}" ]]; then
    # Extract base name without .efi extension
    BASENAME=$(echo "${NAME}" | sed 's/\.efi$//')
    # Look for files that start with the base name followed by underscore and GUID
    EFIFILE=$(find "${SEARCHPATHS}" -maxdepth 1 -type f -name "${BASENAME}_*.efi" 2>/dev/null | head -1)
  fi
  
  if [[ -z "${EFIFILE}" ]]; then
    echo "Warning: EFI file not found for ${NAME}"
    continue
  fi

  ADDR=$(${PEINFO} "${EFIFILE}" 2>/dev/null \
        | grep -A 5 text | grep VirtualAddress | awk '{print $2}')

  if [[ -z "${ADDR}" ]]; then
    echo "Warning: No .text VirtualAddress found for ${NAME}"
    continue
  fi

  TEXT=$(python3 -c "print(hex(${BASE} + ${ADDR}))")

  # Get the actual EFI filename (might be GUID-based) and derive debug filename
  ACTUAL_EFINAME=$(basename "${EFIFILE}")
  SYMS=$(echo "${ACTUAL_EFINAME}" | sed 's/\.efi$/.debug/')
  SYMFILE=$(find "${SEARCHPATHS}" -maxdepth 1 -type f -name "${SYMS}" 2>/dev/null)

  # If GUID-based debug file not found, try original name
  if [[ -z "${SYMFILE}" ]]; then
    SYMS=$(echo "${NAME}" | sed 's/\.efi$/.debug/')
    SYMFILE=$(find "${SEARCHPATHS}" -maxdepth 1 -type f -name "${SYMS}" 2>/dev/null)
  fi

  if [[ -z "${SYMFILE}" ]]; then
    echo "Warning: No .debug file found for ${NAME} (tried ${ACTUAL_EFINAME} and ${NAME})"
    continue
  fi

  echo "add-symbol-file ${SYMFILE} ${TEXT}"
done
