# Synology AMD GPU Monitor 0.4.4

Read-only AMD GPU telemetry in a floating DSM window.

![AMD GPU Monitor with amdgpu_top console](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/d9b4653/docs/amd-gpu-monitor.png)

### What's new

- Bundles the centralized x86_64 `amdgpu_top` v0.1.2 runtime and its private libdrm libraries. One runtime replaces the separate kernel 4 and kernel 5 copies.
- Verifies the downloaded archive and every file listed in its manifest during packaging, then includes that manifest in the SPK.

GPU utilization, VRAM, temperature, fan, clock, and power cards remain available when the hardware exposes those values. **Show Console** opens `amdgpu_top`; its VRAM data can supplement missing DSM sysfs values. An active AMD DRM kernel driver is required.

SPK SHA-256: `d624d80d10967de6ca431afb9d49e1bc7d663a94ae982f04ac89d558a9a100ef`

---

# Synology AMD GPU Monitor 0.4.4 (한국어)

DSM 플로팅 창에서 AMD GPU 상태를 읽기 전용으로 표시합니다.

### 변경 사항

- 중앙 관리되는 x86_64 `amdgpu_top` v0.1.2 런타임과 전용 libdrm 라이브러리를 포함합니다. 기존 커널 4·5별 사본을 단일 런타임으로 통합했습니다.
- 패키징할 때 다운로드한 압축파일과 매니페스트에 기재된 각 파일의 해시를 검증하고, 매니페스트를 SPK에 포함합니다.

GPU 사용률·VRAM·온도·팬·클럭·전력은 하드웨어가 제공하는 범위에서 표시합니다. **Show Console**에서 `amdgpu_top`을 볼 수 있으며, DSM sysfs 값이 없을 때 VRAM 정보의 대체 소스로 활용합니다. AMD DRM 커널 드라이버가 활성화되어 있어야 합니다.

SPK SHA-256: `d624d80d10967de6ca431afb9d49e1bc7d663a94ae982f04ac89d558a9a100ef`
