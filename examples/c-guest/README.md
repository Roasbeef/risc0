# C Guest Program Example

> Warning: this example is still experimental, but the current `make execute`,
> `make prove`, `make execute-standalone`, and `make prove-standalone` paths
> were all revalidated on the current latest lane in this fork.

This example is a template of a basic program written in C.

The current host flow packages the built guest ELF together with
`v1compat.elf` before handing it to the executor/prover. On current `main`,
passing the raw ELF directly is no longer sufficient.

## Quick Start

First, make sure [rustup] is installed.

Then, install the [Risc Zero toolchain](https://dev.risczero.com/api/zkvm/install).

To build all methods and execute the method within the zkVM, run the following
command:

```bash
make execute
```

or to prove:

```bash
make prove
```

For the deterministic published-commit archive path that avoids checkout-path
drift in `libzkvm_platform.a`, prefer:

```bash
make execute-standalone
```

or:

```bash
make prove-standalone
```

Those targets build the platform archive through `make platform-standalone`
first, then compile and run the example guest against that archive. Keep the
older `make execute` / `make prove` path for local workspace iteration only.

If you want the most reproducible published-commit path, prefer the standalone
targets.

For more info on the instructions run, see the [Makefile](./Makefile).

[rustup]: https://rustup.rs
