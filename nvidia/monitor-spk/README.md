# Synology NVIDIA GPU Monitor

### Version 0.6.5

- No longer reads, backs up, patches, or restores DSM Resource Monitor's
  `resource.js` or its compressed copy.
- Keeps the `support_nvidia_gpu=yes` setting and standalone NVIDIA GPU Monitor
  registration.

This SPK provides one read-only command and an optional UI
experiment:

```sh
/var/packages/syno-nvidia-gpu-monitor/target/bin/syno-nvidia-gpu-monitor --json
```

The standalone floating monitor uses NVML and does not modify DSM Resource
Monitor's private UI files or provide GPU values to DSM's private Utilization
API. Uninstall restores the synoinfo settings captured at installation.

It emits the DSM GPU metric schema using NVML and KiB memory units. It has no
daemon and makes no global loader changes. A supported `syno-nvidia-driver`
runtime must already be active.

The DSM Resource Monitor bridge remains a separate Phase 2 research task.
