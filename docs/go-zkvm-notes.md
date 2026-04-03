# Go / TinyGo zkVM Notes

This note records the parts of the risc0 tree that the sibling Go/TinyGo guest
workflow depends on.

## Main Artifacts Used By `go-zkvm`

### Platform Archive

The reusable guest-side syscall veneer comes from the C guest example flow:

- `examples/c-guest`
- `examples/c-guest/guest/out/platform/riscv32im-risc0-zkvm-elf/release/libzkvm_platform.a`

This archive is what the newer TinyGo `zkvm-platform` target links against.

### Kernel ELF

The current packaged guest flow uses:

- `risc0/zkos/v1compat/elfs/v1compat.elf`

The TinyGo user ELF and this kernel half need to come from the same current
risc0 lane.

### Rust Host / Prover Crates

The current local Go guest host uses:

- `risc0/zkvm`

with the in-process prove path enabled so the host is not silently delegating to
an older external `r0vm`.

## Prover backends on v3.1.0

The upstream release selects CUDA for a CUDA-enabled build and CPU otherwise.
This includes CPU proving on Apple Silicon. Setting `RISC0_FORCE_CPU_PROVER=1`
in a CUDA build selects CPU for both segment and recursion proving.

Build and verify receipts with the v3.1.0 host. If selecting the external
prover explicitly, install the matching `r0vm` 3.1.0. Regenerate receipts
created with previous circuits before relying on them.
