# Synology Intel GPU Monitor 0.3.1

Read-only Intel iGPU telemetry in a floating DSM window.

![Intel GPU Monitor with intel_gpu_top console](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/d9b4653/docs/intel-gpu-monitor.png)

### What's included

- i915 GPU utilization and clock cards, with the detected Intel graphics chipset name.
- An optional **Show Console** view powered by the bundled `intel_gpu_top` runtime.
- A power fallback from `intel_gpu_top` when the GPU hwmon value is unavailable.
- An explicitly labelled **System Temperature** proxy when no GPU temperature sensor exists; this is not GPU die temperature.
- No persistent telemetry daemon.

The Intel DRM driver must already be active. Sensor availability varies by hardware and kernel. The HD Graphics 630 in the screenshot is a test device, not a GPU compatibility limit.

---

# Synology Intel GPU Monitor 0.3.1 (한국어)

DSM 플로팅 창에서 Intel iGPU 상태를 읽기 전용으로 표시합니다.

### 주요 기능

- i915 GPU 사용률·클럭 카드와 감지된 Intel 그래픽 칩셋 이름.
- 번들된 `intel_gpu_top`을 표시하는 선택적 **Show Console** 화면.
- GPU hwmon 전력 값이 없으면 `intel_gpu_top` 값으로 대체.
- GPU 온도 센서가 없으면 **System Temperature**로 명확히 표시하는 DSM 시스템 온도 대체값. 이는 GPU 자체 온도가 아닙니다.
- 상주 텔레메트리 데몬 없음.

Intel DRM 드라이버가 미리 활성화되어 있어야 합니다. 센서 제공 여부는 하드웨어와 커널에 따라 달라집니다. 캡처의 HD Graphics 630은 테스트 장비 예시이며 지원 GPU 범위를 뜻하지 않습니다.
