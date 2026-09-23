# GPU Monitor Console Integration Design

## Scope

The standalone AMD, NVIDIA, and Intel monitor packages share one interaction
model. Each vendor page shows three primary sensor cards first; a `Show
Console` checkbox below the cards reveals the matching interactive console.
The console is hidden and stopped by default.

| Vendor | Sensor cards | Console |
|---|---|---|
| AMD | GPU utilization, temperature, VRAM/clock summary | `amdgpu_top` |
| NVIDIA | GPU utilization, temperature, VRAM summary | `nvidia-smi` |
| Intel | GPU utilization, frequency, temperature/power summary | `intel_gpu_top` |

## UI contract

The WebUI is copied from the corresponding implementation in
`mshell-manager/src/ui/{amd-monitor,nvidia-monitor,intel-monitor}.html`.
The following behaviour is retained without redesign:

- DSM floating AppWindow dimensions, responsive layout, dark-theme handling,
  card spacing, typography, and console terminal styling.
- Five-second refresh for sensors, ten-sample moving averages where already
  used, and 50-slot right-to-left history graphs.
- `Show Console` starts the console only after an explicit user action. Hiding
  it stops the process and removes the temporary reverse-proxy route.
- Console failures are shown in the page and never make the telemetry cards
  unavailable.

The standalone pages must only change API URLs and package names. They must
not create a second, divergent console implementation.

## Runtime reuse

The console transport is the same as MSHELL Manager: a package-private `ttyd`
instance, a dedicated localhost port, an nginx WebSocket reverse-proxy
location, and a request CGI that validates the DSM administrator session
before starting or stopping the process. Each vendor gets its own port and
PID/route namespace so consoles cannot terminate one another.

The lifecycle scripts must remove the route, stop the process, and restore any
temporary state during uninstall or upgrade. No persistent telemetry daemon,
global symlink, DSM Resource Monitor patch, or kernel-module change is part of
this design.

## Binary policy

- AMD: reuse the verified `syno-amdgpu-top` runtime archive and its private
  libraries; do not rebuild it as part of every monitor UI change.
- Intel: reuse the verified `syno-intel-gpu-top` runtime archive, including
  `intel_gpu_top.real` and its private libpci/libudev dependencies.
- NVIDIA: invoke the installed driver’s `nvidia-smi`; it is tied to the
  installed NVML/driver version and must not be bundled from an unrelated
  release.
- `ttyd`: copy the tested MSHELL Manager binary for the supported DSM
  x86_64 baseline and record its SHA-256 in the build manifest.

Every imported runtime is copied into the package-private target tree and is
selected by an absolute path. PATH lookup and system-wide replacement are
prohibited. The build records source URL, version, architecture, and SHA-256.

## Privilege and compatibility

The console CGI is unprivileged and delegates only fixed `start`, `stop`, and
`status` actions to the package’s narrowly scoped setuid helper, following the
existing MSHELL Manager whitelist model. No caller-supplied command or path is
accepted. Standard sensor collection remains read-only and request-driven.

The first implementation targets DSM x86_64. Kernel 5.10.55 and 4.4.x
differences affect sensor availability, not the console layout. Unsupported
metrics are rendered as `Unavailable`; a missing optional top binary must not
prevent package installation.

## Acceptance checks

1. Install each SPK with no running service and verify the package remains
   install-only until `Show Console` is selected.
2. Verify each console starts only its own `ttyd`, route, and PID file.
3. Verify refresh, hide, upgrade, uninstall, and browser reload leave no
   orphan process or nginx configuration.
4. Compare screenshots against `mshell-manager-rel/docs/05-nvidia.png`,
   `07-amd-gpu-console.png`, and `07-intel-GPU.png`.
5. Confirm sensor cards continue working when the console binary is absent or
   unsupported.
