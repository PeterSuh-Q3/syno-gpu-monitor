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

The checked-in profiles under `profiles/` are package-owned constants, not
user configuration. A package's privileged helper loads exactly one profile
selected at compile time and then executes `console-control.sh`; the WebUI CGI
may select only `start`, `stop`, or `status`.

`validate-package.sh` performs non-destructive checks on an unpacked SPK work
tree. After installation on DSM, `validate-console.sh` exercises start,
status, stop, repeated stop, nginx validation, and cleanup. It is intended for
upgrade, uninstall, and reboot regression checks; it does not alter DSM-owned
files beyond the package's temporary console route.
