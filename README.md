# Synology GPU Monitor

Cross-vendor GPU telemetry and floating DSM monitor packages, starting with AMD Radeon GPUs.

The AMD monitor will follow the proven NVIDIA GPU Monitor model: a read-only DSM AppWindow, a small request-driven collector, and no persistent daemon or kernel-module changes.

## Repository layout

- `amd/` — AMD Radeon sysfs/DRM monitor and SPK work
- `nvidia/` — imported Synology NVIDIA GPU Monitor package implementation
- `intel/` — reserved for Intel iGPU telemetry and monitor integration

See [AMD GPU Monitor design](docs/amd-gpu-monitor-design.md).

## Shared console design

AMD, NVIDIA, and Intel monitors use the same card-plus-console interaction
model. The standalone packages reuse MSHELL Manager's tested floating console
implementation rather than introducing a second terminal UI. See
[GPU Console Integration Design](docs/gpu-console-integration-design.md) for
the exact `Show Console`, `ttyd`, nginx, privilege-helper, binary provenance,
and cleanup contract.
