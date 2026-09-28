# Synology Intel GPU Monitor 0.3.2

Read-only Intel iGPU telemetry in a floating DSM window.

![Intel GPU Monitor with intel_gpu_top console](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/d9b4653/docs/intel-gpu-monitor.png)

### What's new

- Bundles the centralized x86_64 `intel_gpu_top` v0.1.3 runtime and its private libraries.
- Verifies the downloaded archive and every file listed in its manifest during packaging, then includes that manifest in the SPK.

The monitor retains i915 utilization and clock cards, chipset naming, an optional **Show Console** view, and an `intel_gpu_top` power fallback. When a GPU temperature sensor is unavailable, **System Temperature** is labelled as a system proxy. An active Intel DRM driver and working i915 PMU are required for `intel_gpu_top` telemetry.

SPK SHA-256: `708a9c70690aa0449ade7cbb85bfa557abf9a7a28294003094f600c98e775e69`

---

# Synology Intel GPU Monitor 0.3.2 (한국어)

DSM 플로팅 창에서 Intel iGPU 상태를 읽기 전용으로 표시합니다.

### 변경 사항

- 중앙 관리되는 x86_64 `intel_gpu_top` v0.1.3 런타임과 전용 라이브러리를 포함합니다.
- 패키징할 때 다운로드한 압축파일과 매니페스트에 기재된 각 파일의 해시를 검증하고, 매니페스트를 SPK에 포함합니다.

i915 사용률·클럭, 칩셋 이름, 선택형 **Show Console**, `intel_gpu_top` 전력 대체값을 제공합니다. GPU 온도 센서가 없으면 DSM 시스템 온도를 **System Temperature** 대체값으로 명확히 표시합니다. `intel_gpu_top` 텔레메트리에는 Intel DRM 드라이버와 동작하는 i915 PMU가 필요합니다.

SPK SHA-256: `708a9c70690aa0449ade7cbb85bfa557abf9a7a28294003094f600c98e775e69`
