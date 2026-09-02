# AMD GPU Monitor Design

## Goal

Provide a standalone Synology DSM floating monitor for AMD GPUs using the already-installed `amdgpu.ko` and userspace runtime. The package must remain independent of the NVIDIA monitor and must not modify DSM private APIs or kernel files.

## Architecture

```text
DSM AppWindow
    -> static WebUI
    -> request-driven API CGI
    -> AMD telemetry collector
    -> sysfs + DRM/libdrm + optional amdgpu_top
```

The package is installable-only from Package Center; it has no long-running service. `start-stop-status` returns success without launching a daemon. The UI opens as a DSM floating window from the main menu, matching the NVIDIA monitor interaction model.

## Telemetry sources

1. `/sys/class/drm/card*/device` and hwmon provide the portable baseline: GPU busy percentage, VRAM/GTT usage where exposed, temperature, fan speed, power, and clock states.
2. DRM/libdrm identifies the render node and card identity without requiring a vendor-specific control daemon.
3. `amdgpu_top` is an optional enhanced source for engine activity (GFX, Compute, DMA, Video decode/encode). If unavailable or unsupported on an older DSM 4.4 kernel, the UI reports unavailable rather than failing installation.
4. OpenCL/Vulkan are not telemetry dependencies; they remain workload runtimes supplied by the AMD runtime package.

## Initial cards

- GPU utilization
- VRAM used / total (MiB and percent)
- GFX/Compute activity
- Video encode and decode activity when exposed by the kernel
- Temperature
- Fan speed
- GPU clock and memory clock

The UI should use the NVIDIA monitor's established 5-second refresh, 10-sample moving average for headline utilization, and 50-slot right-to-left history graphs. Unsupported metrics display `Unavailable`.

## Security and lifecycle

- Collector is read-only and request-driven.
- No `LD_PRELOAD`, kernel-module insertion, or writes to DSM-owned JavaScript/API files.
- No setuid helper is required for baseline sysfs/DRM reads. A narrowly scoped helper may be added only if a specific hwmon node requires it, using the same `conf/privilege` pattern as the NVIDIA package.
- Package metadata uses DSM `x86_64` architecture and broad DSM version bounds, with compatibility tested on kernel 5.10.55 and kernel 4.4.x platforms.

## Phased implementation

1. **Collector prototype:** enumerate `/dev/dri/renderD*`, read sysfs/hwmon, emit stable JSON.
2. **API and WebUI:** add AppWindow, four baseline cards, then clock/thermal cards and 50-slot graphs.
3. **amdgpu_top integration:** consume machine-readable output when available; feature-detect version/options and fall back cleanly.
4. **SPK packaging:** install-only lifecycle, icon, privilege validation, and Package Center installation tests on representative DSM 7.4 platforms.
5. **Compatibility validation:** verify Renoir, Polaris, and RX 6600-class devices; separately mark kernel 4.4 experimental telemetry limitations.

## Relationship to NVIDIA GPU Monitor

The UI lifecycle, AppWindow registration, refresh/averaging policy, package safety rules, and release workflow are intentionally shared. The collector is vendor-specific: AMD uses sysfs/DRM/amdgpu_top rather than NVML, and must never assume NVENC/NVDEC terminology.
