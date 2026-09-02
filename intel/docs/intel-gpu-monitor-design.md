# Intel GPU Monitor Design

## Goal

Provide an independent floating DSM monitor for Intel integrated GPUs while
remaining useful on DSM systems that have i915 backports but do not include
`intel_gpu_top`, perf tooling, or a complete desktop userspace stack.

## Architecture

```text
DSM AppWindow → WebUI → request-driven JSON CGI → DRM sysfs / hwmon collector
```

The package follows the AMD and NVIDIA monitor interaction model: an
install-only SPK, no persistent telemetry daemon, and a standalone DSM
floating window. It must not patch DSM Resource Monitor private APIs.

## Baseline sources

The collector discovers Intel DRM cards by checking `/sys/class/drm/card*/device/vendor`
for `0x8086`. It then feature-detects each readable node instead of assuming
a particular i915 generation.

| Metric | Preferred source | Availability |
|---|---|---|
| GPU busy percentage | `gt_busy_percent` | Available on many i915 builds; optional |
| GPU frequency | `gt_cur_freq_mhz` or `gt_act_freq_mhz` | Generation/kernel dependent |
| Requested frequency | `gt_RPn_freq_mhz` / `gt_max_freq_mhz` | Optional |
| Temperature | Intel GPU hwmon `temp*_input` | Optional; often CPU package sensor instead |
| Power | hwmon `power*_average` | Optional |
| Render node | `/dev/dri/renderD*` | Required for VA-API validation, not telemetry |

There is no portable sysfs equivalent of NVIDIA NVENC/NVDEC utilization or
AMD per-engine statistics. Render/video/blitter engine percentages therefore
remain explicitly optional. They should be added only when a stable kernel
interface is exposed; `intel_gpu_top` parsing is not a baseline dependency.

## UI

Initial UI uses the established monitor layout:

- Intel GPU utilization: 10-sample average with a 50-slot right-to-left graph
- GPU clock
- Temperature
- Power where available
- Render node and driver identity in a compact status row
- Unsupported values shown as `Unavailable`, never as an installation error

The Intel package should use a distinct blue/indigo icon while preserving the
same DSM AppWindow, icon sizes, and package lifecycle safety as AMD/NVIDIA.

## Compatibility policy

- Primary scope: i915-backed Intel integrated GPUs on DSM 7.x x86_64.
- Feature detection is mandatory because DSM's i915 backports and kernel 4.4/
  5.10 builds expose different sysfs nodes.
- The collector is read-only and requires no root helper for standard sysfs
  reads. A helper is only justified if DSM WebUI symlink registration requires
  one, as in the AMD/NVIDIA packages.
- VA-API is not a collector dependency. It is used only by validation tests
  to verify that the selected render node can service media workloads.

## Implementation phases

1. Build a feature-detecting C collector that identifies `0x8086` DRM cards
   and emits stable JSON.
2. Validate its sysfs map on Gemini Lake, Ice Lake, Alder Lake/N-series, and
   older i915-backport DSM systems.
3. Add the shared floating WebUI/SPK framework and Intel-specific icon.
4. Add optional engine metrics only after a stable DSM-exposed source is
   confirmed; do not make `intel_gpu_top` a package requirement.
