## Intel GPU Monitor 0.3.0

> Screenshot of the current UI, including features added after the 0.3.0 release asset. The image is not a feature guarantee for the 0.3.0 SPK.

![Current Intel GPU Monitor dashboard and intel_gpu_top console](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/main/docs/intel-gpu-monitor.png)

A standalone DSM WebUI for read-only Intel iGPU telemetry.

- Detects Intel DRM devices automatically.
- Uses i915 PMU counters for system-wide GPU-engine utilization.
- Shows active and maximum GPU clock values where the i915 driver provides them.
- Includes a 10-sample average utilization card and 50-slot history graph.
- Uses a narrow DSM-managed privileged collector only for i915 PMU access; the WebUI itself remains unprivileged.

> In the 0.3.0 release asset, temperature and power remain unavailable on systems without compatible i915 hwmon nodes. The system-temperature proxy and `intel_gpu_top` power fallback visible in the current screenshot were added later.

---

## Intel GPU Monitor 0.3.0 (한국어)

> 위 캡처는 0.3.0 릴리즈 자산 이후 추가된 기능을 포함한 현재 UI입니다. 0.3.0 SPK의 기능을 모두 나타내는 화면은 아닙니다.

읽기 전용 Intel iGPU 텔레메트리를 제공하는 독립 DSM WebUI 패키지입니다.

- Intel DRM 장치를 자동 감지합니다.
- i915 PMU 카운터로 시스템 전체 GPU 엔진 사용률을 수집합니다.
- i915 드라이버가 제공하는 경우 현재·최대 GPU 클럭을 표시합니다.
- GPU 사용률은 10회 평균 및 50슬롯 이력 그래프로 표시합니다.
- i915 PMU 접근에만 범위를 제한한 DSM 관리형 권한 수집기를 사용하며, WebUI 전체를 root로 실행하지 않습니다.

> 0.3.0 자산에서는 i915 hwmon 노드가 없는 장비의 온도·전력 값이 표시되지 않습니다. 캡처에 보이는 시스템 온도 대체값과 `intel_gpu_top` 전력 대체 경로는 이후 추가되었습니다.
