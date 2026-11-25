#!/usr/bin/env bash
# Materialize the stable Go guest port without disturbing the development tree.
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 NEW_CHECKOUT_DIRECTORY" >&2
  exit 2
fi

here=$(cd "$(dirname "$0")" && pwd -P)
upstream=22c5fb90522cb4d9427d4af6c05e747d20be2b7f
tree=71eaa3adab3f5da9fc26c8e64c0456f9d71223a7
dest=$1
mkdir -- "$dest"
GIT_LFS_SKIP_SMUDGE=1 git clone --depth 1 --branch v3.1.0 \
  https://github.com/risc0/risc0.git "$dest"

cd -- "$dest"
if [[ $(git rev-parse HEAD) != "$upstream" ]]; then
  echo "v3.1.0 does not match the pinned upstream commit" >&2
  exit 1
fi
git apply --index "$here/go-guests.patch"
if [[ $(git write-tree) != "$tree" ]]; then
  echo "patched checkout differs from the reviewed release tree" >&2
  exit 1
fi

# Build paths and fingerprints can depend on HEAD. Give every checkout the
# same detached commit, irrespective of the local git identity and clock.
export GIT_AUTHOR_NAME='go-zkvm release tooling' GIT_AUTHOR_EMAIL='go-zkvm@localhost'
export GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
export GIT_AUTHOR_DATE='2026-11-25T00:00:00Z' GIT_COMMITTER_DATE='2026-11-25T00:00:00Z'
port=$(git -c commit.gpgSign=false commit-tree "$tree" -p "$upstream" \
  -m 'Port the Go guest platform and host to RISC Zero v3.1.0')
git update-ref --no-deref HEAD "$port" "$upstream"
git lfs install --local
git lfs pull --include='risc0/circuit/*/src/zkrs.tar.xz'
for archive in risc0/circuit/{recursion,recursion-control}-zkrs/src/zkrs.tar.xz; do
  git cat-file blob "HEAD:$archive" | cmp - <(git lfs pointer --file="$archive")
done
echo "Prepared Go guest toolchain at $port"
