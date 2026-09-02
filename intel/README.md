# Intel GPU Monitor

`synology-intel-gpu-monitor` is a DSM 7+ x86_64 package for a self-contained Intel GPU telemetry window. It reads Intel DRM sysfs and hwmon nodes directly; `intel_gpu_top` is not bundled or required.

Build a package with Docker Desktop running:

```sh
cd intel
./scripts/build-spk.sh
```

The package is intentionally read-only. Its WebUI bridge uses the same narrow, fixed-action privileged helper pattern already validated by the AMD monitor so DSM Package Center installation, update, and removal can manage only the package-owned UI symlink.

Intel iGPU monitor implementation space for Synology DSM.

See [the design document](docs/intel-gpu-monitor-design.md).
