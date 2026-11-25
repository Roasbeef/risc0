# RISC Zero v3.1.0 for Go guests

Run the following from the directory containing your go-zkvm checkout. The
destination must be new. The script needs Git, Git LFS, and access to GitHub.

```sh
./risc0-port/releases/v3.1.0/prepare.sh ./risc0
```

The development branch and the upstream stable release use different proving
circuits. The script clones the official release, verifies its commit, applies
the reviewed Go guest delta, checks the resulting Git tree and fetches the two
recursion circuit archives from upstream LFS. Its output is a normal detached
Git checkout at a reproducible commit. Inspect the port with
`git -C risc0 diff HEAD^ HEAD`.

The delta carries the C/TinyGo platform archive, explicit guest heap
initialization, v1compat guest packaging, and the fork's CPU override for
CUDA builds. The proving circuits and verifier parameters come from upstream
v3.1.0. Stable uses CPU on Apple Silicon. Regenerate receipts created with
older circuits and use r0vm 3.1.0 for external proving.

[Upstream release](https://github.com/risc0/risc0/releases/tag/v3.1.0) ·
[Go toolchain upgrade](https://github.com/Roasbeef/go-zkvm/issues/6)
