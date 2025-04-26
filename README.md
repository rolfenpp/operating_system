# Minimal OS

A bootloader + protected mode kernel written in x86 assembly and C.

## Features
- Custom bootloader in real mode
- Switches to protected mode
- Loads a 32-bit kernel
- Simple VGA text output
- Keyboard interrupt handling

## Build and Run

```bash
make clean
make run
