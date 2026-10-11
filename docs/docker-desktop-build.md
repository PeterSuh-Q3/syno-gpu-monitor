# macOS Docker Desktop Build Guide

This repository builds DSM x86_64 monitor packages with the Debian 12 native
x86_64 builder used by the Intel GPU Top project. The monitor executables do
not use a Synology platform cross-toolchain.

## Requirements

- macOS with Docker Desktop running
- Git checkout of `syno-gpu-monitor`
- Docker Desktop Linux VM with amd64 emulation enabled
- Docker Desktop File Sharing access for the repository directory
- Network access to Docker Hub

The build scripts default to:

```text
dante90/syno-intel-gpu-top-builder:debian12-native
/usr/bin/gcc
```

The compiler runs inside an amd64 Debian 12 container and produces x86_64
collectors and helpers. The image uses the DSM 7.4 glibc 2.36 baseline; the
monitor sources currently require no newer GLIBC symbols. The host architecture
does not change the target.

## Prepare Docker Desktop

Start Docker Desktop and pull the compiler image once:

```sh
docker pull dante90/syno-intel-gpu-top-builder:debian12-native
docker image inspect dante90/syno-intel-gpu-top-builder:debian12-native
```

On Apple Silicon, Docker Desktop must be allowed to run amd64 emulation. The
build scripts explicitly pass `--platform linux/amd64`.

If Docker reports a bind-mount permission error, add the parent directory of
this checkout under Docker Desktop → Settings → Resources → File Sharing.

## Build one package

```sh
cd /Users/yousuk/syno-gpu-monitor

cd amd   && ./scripts/build-spk.sh
cd ../nvidia && ./scripts/build-spk.sh
cd ../intel  && ./scripts/build-spk.sh
```

Each script creates a temporary `work/` tree and writes the SPK under that
vendor's `dist/` directory. Existing source files are not modified by the
container compiler.

## Build all packages

```sh
cd /Users/yousuk/syno-gpu-monitor
for vendor in amd nvidia intel; do
  (cd "$vendor" && ./scripts/build-spk.sh) || exit 1
done
```

To use another compiler image or compiler path without editing the scripts:

```sh
GPU_MONITOR_BUILDER_IMAGE=dante90/syno-intel-gpu-top-builder:debian12-native \
GPU_MONITOR_CC=/usr/bin/gcc \
(cd amd && ./scripts/build-spk.sh)
```

## Verify the result

```sh
find amd/dist nvidia/dist intel/dist -name '*.spk' -type f -print
tar -tf amd/dist/*.spk | sed -n '1,80p'
```

The package must contain `INFO`, `package.tgz`, lifecycle scripts, the
vendor WebUI, the shared `gpu-console.js`/`gpu-console.css`, and the private
console runtime staging directory.

For an unpacked work tree, run:

```sh
common/console/validate-package.sh <unpacked-package-root>
```

The live DSM lifecycle test is documented in
`common/console/validate-console.sh`; it must be run on a test NAS, not on the
macOS host.

## Console runtime note

The current staging scripts copy the tested MSHELL Manager `ttyd` binary from:

```text
/Users/yousuk/mshell-manager/src/bin/ttyd
```

That path must exist on the macOS host, or the build will stop during staging.
The long-term reproducible solution is to move the verified `ttyd` binary into
repository-managed release assets or a dedicated builder image and verify its
SHA-256 during the build.

## Clean rebuild

Only generated vendor work trees may be removed:

```sh
rm -rf amd/work nvidia/work intel/work
```

Do not remove `sources/`, checked-in runtime manifests, or unrelated files.
