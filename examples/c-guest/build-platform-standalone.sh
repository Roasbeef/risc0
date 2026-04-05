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

git_url_to_cargo_url() {
  case "$1" in
    git@*:* )
      local host_path="${1#git@}"
      local host="${host_path%%:*}"
      local path="${host_path#*:}"
      printf 'ssh://git@%s/%s\n' "${host}" "${path}"
      ;;
    * )
      printf '%s\n' "$1"
      ;;
  esac
}

REMOTE_URL_RAW="${PLATFORM_GIT_URL:-$(git -C "${REPO_ROOT}" remote get-url origin)}"
REMOTE_URL="$(git_url_to_cargo_url "${REMOTE_URL_RAW}")"
GIT_REV="${PLATFORM_GIT_REV:-$(git -C "${REPO_ROOT}" rev-parse HEAD)}"

mkdir -p "${TMPDIR}/src" "${OUT_DIR}"
cp "${ROOT_DIR}/platform/src/lib.rs" "${TMPDIR}/src/lib.rs"
cp "${REPO_ROOT}/Cargo.lock" "${TMPDIR}/Cargo.lock"

cat > "${TMPDIR}/Cargo.toml" <<EOF
[package]
name = "zkvm-platform-standalone"
version = "0.1.0"
edition = "2024"

[dependencies]
risc0-binfmt = { git = "${REMOTE_URL}", rev = "${GIT_REV}", package = "risc0-binfmt", default-features = false }
risc0-zkp = { git = "${REMOTE_URL}", rev = "${GIT_REV}", package = "risc0-zkp", default-features = false }
risc0-zkvm-platform = { git = "${REMOTE_URL}", rev = "${GIT_REV}", package = "risc0-zkvm-platform", features = ["rust-runtime", "export-syscalls"] }

[profile.release]
lto = true
EOF

BUILD_RUSTFLAGS="--remap-path-prefix=${TMPDIR}=/standalone-src --remap-path-prefix=${HOME}/.cargo/registry/src=/cargo/registry/src -C metadata=standalone ${RUSTFLAGS:-}"

echo "building standalone platform archive from ${REMOTE_URL} @ ${GIT_REV}" >&2

CARGO_NET_GIT_FETCH_WITH_CLI=true RUSTFLAGS="${BUILD_RUSTFLAGS}" cargo +risc0 rustc \
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
