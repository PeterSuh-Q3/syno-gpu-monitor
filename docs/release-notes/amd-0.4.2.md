# Synology AMD GPU Monitor 0.4.2

> Screenshot of the current UI, including features added after the 0.4.2 release asset. The image is not a feature guarantee for the 0.4.2 SPK.

![Current AMD GPU Monitor dashboard and amdgpu_top console](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/main/docs/amd-gpu-monitor.png)

A read-only AMD GPU telemetry monitor for Synology DSM.

## Highlights

- DSM main-menu app with a floating monitor window
- GPU utilization with a 10-sample average and 50-slot history graph
- Temperature, fan speed, GPU clock, memory clock, and power telemetry
- Direct DRM sysfs and hwmon collection; no `amdgpu_top` dependency in this release
- Works with the installed `amdgpu` kernel driver and `/dev/dri/renderD*`
- No persistent telemetry daemon and no DSM private API patching

## Notes

In the 0.4.2 release asset, VRAM usage requires kernel `mem_info_vram_*` values. The `amdgpu_top` VRAM fallback shown in the current screenshot was added later.

Tested on DSM 7.4 with AMD Renoir Radeon Vega graphics (PCI ID `1002:1636`).

---

# Synology AMD GPU Monitor 0.4.2 (한국어)

> 위 캡처는 0.4.2 릴리즈 자산 이후 추가된 기능을 포함한 현재 UI입니다. 0.4.2 SPK의 기능을 모두 나타내는 화면은 아닙니다.

Synology DSM용 읽기 전용 AMD GPU 텔레메트리 모니터입니다.

## 주요 기능

- DSM 메인 메뉴에서 여는 플로팅 모니터 창
- GPU 사용률 10회 평균 및 50슬롯 이력 그래프
- 온도, 팬 속도, GPU 클럭, 메모리 클럭, 전력 텔레메트리
- DRM sysfs·hwmon을 직접 수집하며 이 릴리즈에서는 `amdgpu_top`에 의존하지 않음
- 설치된 `amdgpu` 커널 드라이버 및 `/dev/dri/renderD*`와 함께 동작
- 상주 텔레메트리 데몬 및 DSM 비공개 API 패치 없음

## 참고

0.4.2 자산에서는 커널이 `mem_info_vram_*`를 제공해야 VRAM 사용량을 표시합니다. 캡처에 보이는 `amdgpu_top` VRAM 대체 경로는 이후 추가되었습니다.

DSM 7.4 / AMD Renoir Radeon Vega 그래픽(PCI ID `1002:1636`)에서 검증했습니다.
