# Synology GPU Monitor

Cross-vendor GPU telemetry and floating DSM monitor packages, starting with AMD Radeon GPUs.

The AMD monitor will follow the proven NVIDIA GPU Monitor model: a read-only DSM AppWindow, a small request-driven collector, and no persistent daemon or kernel-module changes.

## Repository layout

- `amd/` — AMD Radeon sysfs/DRM monitor and SPK work
- `nvidia/` — imported Synology NVIDIA GPU Monitor package implementation
- `intel/` — reserved for Intel iGPU telemetry and monitor integration

See [AMD GPU Monitor design](docs/amd-gpu-monitor-design.md).
