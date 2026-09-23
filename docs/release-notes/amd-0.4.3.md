# Synology AMD GPU Monitor 0.4.3

Read-only AMD GPU telemetry in a floating DSM window.

![AMD GPU Monitor with amdgpu_top console](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/d9b4653/docs/amd-gpu-monitor.png)

### What's included

- GPU utilization, VRAM usage, temperature, fan speed, clocks, and power cards.
- The detected AMD chipset name in the window, resolved with the PCI ID database when available.
- An optional **Show Console** view powered by the bundled `amdgpu_top` runtime.
- A VRAM fallback: if DSM does not expose `mem_info_vram_*`, the monitor reads the matching GPU's VRAM values from `amdgpu_top`.
- No persistent telemetry daemon.

The GPU and kernel driver must already be installed and working. Sensor availability depends on the GPU and DSM kernel. The screenshot shows a Radeon PRO WX 3100 test system; it is not a GPU compatibility limit.

---

# Synology AMD GPU Monitor 0.4.3 (한국어)

DSM 플로팅 창에서 AMD GPU 상태를 읽기 전용으로 표시합니다.

### 주요 기능

- GPU 사용률, VRAM 사용량, 온도, 팬 속도, 클럭, 전력 카드.
- PCI ID 데이터베이스를 사용할 수 있으면 감지된 AMD 그래픽 칩셋 이름을 표시.
- 번들된 `amdgpu_top`을 표시하는 선택적 **Show Console** 화면.
- DSM의 `mem_info_vram_*`가 없으면 해당 GPU의 `amdgpu_top` 값으로 VRAM 사용량을 대체.
- 상주 텔레메트리 데몬 없음.

GPU와 커널 드라이버는 미리 설치되어 정상 동작해야 합니다. 센서 제공 여부는 GPU와 DSM 커널에 따라 달라집니다. 캡처의 Radeon PRO WX 3100은 테스트 장비 예시이며 지원 GPU 범위를 뜻하지 않습니다.
