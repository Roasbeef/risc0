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

## Apple Silicon Local Proving

On Apple Silicon, current upstream risc0 uses the Metal-backed prover path by
default for local proving.

That path was explicitly validated while bringing up the current Go guest flow.

## Local CPU Escape Hatch In This Fork

This fork also carries a small local debugging override:

- `RISC0_FORCE_CPU_PROVER=1`

When set, the fork forces both the segment prover and recursion prover onto the
CPU path instead of Metal/CUDA. This is useful for debugging or isolating GPU
startup behavior, but the normal local path on Apple Silicon is still Metal.
