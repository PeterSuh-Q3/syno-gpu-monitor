# AMD collector

`amd-gpu-monitor` is intentionally request-driven and reads only the amdgpu
DRM sysfs and hwmon nodes. Missing nodes produce `-1`/`Unavailable` values;
no `amdgpu_top` or vendor daemon is required.
