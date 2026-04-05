#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd -P)
REPO_ROOT=$(cd "${ROOT_DIR}/../.." && pwd -P)
TMPDIR=$(mktemp -d)
OUT_DIR="${ROOT_DIR}/guest/out/platform/riscv32im-risc0-zkvm-elf/release"
TARGET_DIR="${TMPDIR}/out"

cleanup() {
  rm -rf "${TMPDIR}"
}

trap cleanup EXIT

# The port changes the local C veneer. Its three Rust dependencies come
# from the unmodified, published release and are fetchable from a fresh clone.
REMOTE_URL="${PLATFORM_GIT_URL:-https://github.com/risc0/risc0.git}"
GIT_REV="${PLATFORM_GIT_REV:-22c5fb90522cb4d9427d4af6c05e747d20be2b7f}"

mkdir -p "${TMPDIR}/src" "${OUT_DIR}"
cp "${ROOT_DIR}/platform/src/lib.rs" "${TMPDIR}/src/lib.rs"
cp "${REPO_ROOT}/Cargo.lock" "${TMPDIR}/Cargo.lock"

cat > "${TMPDIR}/Cargo.toml" <<EOF
[package]
name = "zkvm-platform-standalone"
version = "0.1.0"
edition = "2021"

[dependencies]
risc0-binfmt = { git = "${REMOTE_URL}", rev = "${GIT_REV}", package = "risc0-binfmt", default-features = false }
risc0-zkp = { git = "${REMOTE_URL}", rev = "${GIT_REV}", package = "risc0-zkp", default-features = false }
risc0-zkvm-platform = { git = "${REMOTE_URL}", rev = "${GIT_REV}", package = "risc0-zkvm-platform", features = ["rust-runtime", "export-syscalls"] }

[profile.release]
lto = true
EOF

BUILD_RUSTFLAGS="--remap-path-prefix=${TMPDIR}=/standalone-src --remap-path-prefix=${CARGO_HOME:-${HOME}/.cargo}/registry/src=/cargo/registry/src -C metadata=standalone ${RUSTFLAGS:-}"

echo "building standalone platform archive from ${REMOTE_URL} @ ${GIT_REV}" >&2

GIT_LFS_SKIP_SMUDGE=1 CARGO_NET_GIT_FETCH_WITH_CLI=true RUSTFLAGS="${BUILD_RUSTFLAGS}" cargo +risc0 rustc \
  --manifest-path "${TMPDIR}/Cargo.toml" \
  --target riscv32im-risc0-zkvm-elf \
  --lib \
  --crate-type staticlib \
  --release \
  --target-dir "${TARGET_DIR}"

cp \
  "${TARGET_DIR}/riscv32im-risc0-zkvm-elf/release/libzkvm_platform_standalone.a" \
  "${OUT_DIR}/libzkvm_platform.a"

echo "wrote ${OUT_DIR}/libzkvm_platform.a" >&2
