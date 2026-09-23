# Synology NVIDIA GPU Monitor 0.6.3

Read-only NVIDIA GPU telemetry in a floating DSM window.

![NVIDIA GPU Monitor with nvidia-smi console](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/d9b4653/docs/nvidia-gpu-monitor.png)

### What's included

- GPU and VRAM utilization, NVENC/NVDEC activity, temperature, fan speed, and clock cards.
- GPU utilization history and an optional **Show Console** view of `nvidia-smi`.
- NVML-based, request-driven telemetry without a persistent polling daemon.

This is a monitor, not an NVIDIA driver package. A working host driver and NVIDIA userspace runtime are required. The GTX 1650, driver version, and CUDA version visible in the screenshot are examples from the test system, not package requirements.

---

# Synology NVIDIA GPU Monitor 0.6.3 (한국어)

DSM 플로팅 창에서 NVIDIA GPU 상태를 읽기 전용으로 표시합니다.

### 주요 기능

- GPU·VRAM 사용률, NVENC/NVDEC 활동, 온도, 팬 속도, 클럭 카드.
- GPU 사용률 이력과 `nvidia-smi`를 표시하는 선택적 **Show Console** 화면.
- NVML 기반 요청 시 수집 방식으로 상주 폴링 데몬 없음.

이 패키지는 모니터이며 NVIDIA 드라이버를 포함하지 않습니다. 정상 동작하는 호스트 드라이버와 NVIDIA 사용자 공간 런타임이 필요합니다. 캡처의 GTX 1650, 드라이버·CUDA 버전은 테스트 장비 예시이며 설치 조건이 아닙니다.
