# Synology NVIDIA GPU Monitor

### Version 0.6.4

- A DSM Resource Monitor GPU-mask patch is optional: if the DSM-specific
  `resource.js` pattern is not recognized, installation continues without
  modifying those DSM assets.
- The standalone NVIDIA GPU Monitor remains available; only the optional DSM
  Resource Monitor integration may be skipped.
- When the known pattern is present, the patch is applied with a backup and
  restored on uninstall.

This SPK provides one read-only command and an optional UI
experiment:

```sh
/var/packages/syno-nvidia-gpu-monitor/target/bin/syno-nvidia-gpu-monitor --json
```

Version 0.2 additionally exposes DSM Resource Monitor's existing GPU panels
and removes only the misleading “no GPU installed” mask. It does not provide
GPU values to DSM's private Utilization API yet; uninstall restores every
modified DSM file and setting.

It emits the DSM GPU metric schema using NVML and KiB memory units.  It has no
daemon and makes no global loader changes.  The UI experiment makes a small,
backed-up change to DSM Resource Monitor's display JavaScript and restores it
on uninstall.  A supported `syno-nvidia-driver` runtime must already be active.

The DSM Resource Monitor bridge remains a separate Phase 2 research task.
