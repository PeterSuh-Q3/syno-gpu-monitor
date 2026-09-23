# Shared GPU console module

This directory is the common lifecycle layer for the three standalone GPU
monitor packages. It is intentionally small and vendor-neutral. A package
provides fixed values for:

- its package root and WebUI namespace;
- the package-private `ttyd` path;
- the console binary (`amdgpu_top`, `nvidia-smi`, or `intel_gpu_top`);
- a dedicated localhost port, base path, nginx link, config, and PID file.

`console-control.sh` accepts only `start`, `stop`, and `status`. It stops an
existing instance before starting a new one, validates the nginx configuration,
records the actual ttyd PID, and removes both the process and route on stop.
The CGI wrapper must authenticate the DSM administrator and invoke this script
through the package's narrowly scoped setuid helper. It must never pass a
user-supplied command, path, port, or environment value.

The implementation is based on the tested MSHELL Manager flow in
`src/bin/mshell-backend.sh` and its AMD/Intel console CGI/config files. The
template is not a second terminal implementation; it is the extracted common
parameterized layer to be called by each vendor package.

Recommended fixed assignments:

| Vendor | Port | Base path |
|---|---:|---|
| NVIDIA | 17681 | `nvidia-gpu-console` |
| AMD | 17682 | `amdgpu-console` |
| Intel | 17683 | `intel-gpu-console` |
