# GPU Monitor Console Integration Design

## Scope

The standalone AMD, NVIDIA, and Intel monitor packages share one interaction
model. Each vendor page keeps the MSHELL Manager sensor-card layout; a `Show
Console` checkbox in the toolbar reveals the matching console.
The console is hidden and stopped by default.

| Vendor | Sensor cards | Console |
|---|---|---|
| AMD | Seven AMD DRM cards, in two columns | `amdgpu_top` |
| NVIDIA | Eight NVML cards, in four columns | `nvidia-smi` |
| Intel | Four Intel DRM cards, in four columns | `intel_gpu_top` |

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

The standalone pages adapt their collectors' flat JSON fields to the MSHELL
card labels and reuse one shared console controller.

The shared WebUI assets are `common/webui/gpu-console.css` and
`common/webui/gpu-console.js`. A vendor page mounts one controller with its
fixed `console.cgi` and console route URLs, then places the returned panel
in the MSHELL-aligned layout: beside AMD's narrow sensor column, below the
Intel and NVIDIA card grids.

## Runtime reuse

The AMD and Intel console transport reuses MSHELL Manager's tested `ttyd`
binary, dedicated loopback-only ports, nginx WebSocket reverse-proxy
locations, and request CGI that validates the DSM administrator session and
SynoToken before starting or stopping the process. On each start, the root
helper creates a fresh 192-bit URL path and returns it only to the authorized
CGI caller. An unauthenticated request to the predictable console base path
receives 404. NVIDIA follows MSHELL Manager's
existing text-console design: the toolbar toggle reveals an `nvidia-smi`
output panel beneath the cards, and its output is refreshed with the telemetry.

The lifecycle scripts must remove the route, stop the process, and restore any
temporary state during uninstall or upgrade. No persistent telemetry daemon,
global symlink, DSM Resource Monitor patch, or kernel-module change is part of
this design.

## Binary policy

- AMD: reuse verified `syno-amdgpu-top` 0.1.1 runtime assets for both kernel
  4.4.x and 5.10.55, including their private libdrm libraries.
- Intel: reuse the verified `syno-intel-gpu-top` 0.1.2 runtime archive, including
  `intel_gpu_top.real` and its private libpci/libudev dependencies.
- NVIDIA: invoke the installed driver’s `nvidia-smi` for the output panel; it
  is tied to the installed NVML/driver version and must not be bundled from an
  unrelated release.
- `ttyd`: copy the tested MSHELL Manager binary from the sibling local clone
  (or `TTYD_SOURCE`) and verify its pinned SHA-256 at build time.

Every imported runtime is copied into the package-private target tree and is
selected by an absolute path. PATH lookup and system-wide replacement are
prohibited. The build records source URL, version, architecture, and SHA-256.

## Privilege and compatibility

The console CGI is unprivileged and delegates only fixed `start`, `stop`, and
`status` actions to the package’s narrowly scoped setuid helper. The helper
executes only root-owned package scripts and clears its inherited environment.
No caller-supplied command or path is accepted. The ttyd process is read-only
(`-W` is absent), bound to loopback, and exits when its last client disconnects.
Standard sensor collection remains read-only and request-driven.

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
