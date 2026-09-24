# Synology GPU Monitors — AMD 0.4.3 · NVIDIA 0.6.3 · Intel 0.3.1

Download the three standalone Synology DSM GPU Monitor packages from this release. Install only the package for the GPU vendor in your NAS.

## AMD GPU Monitor 0.4.3

AMD telemetry cards for utilization, VRAM, temperature, fan, clocks, and power. Includes chipset naming, an `amdgpu_top` VRAM fallback, and an optional **Show Console** view.

![AMD GPU Monitor](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/fdd7cb9/docs/amd-gpu-monitor.png)

## NVIDIA GPU Monitor 0.6.3

NVML telemetry for GPU and VRAM utilization, NVENC/NVDEC activity, temperature, fan, and clocks, with an optional `nvidia-smi` console.

![NVIDIA GPU Monitor](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/fdd7cb9/docs/nvidia-gpu-monitor.png)

## Intel GPU Monitor 0.3.1

i915 utilization and clock telemetry with chipset naming. Power can use `intel_gpu_top`; when GPU temperature is unavailable, DSM system temperature is clearly presented as a proxy.

![Intel GPU Monitor](https://raw.githubusercontent.com/PeterSuh-Q3/syno-gpu-monitor/fdd7cb9/docs/intel-gpu-monitor.png)

---

# Synology GPU Monitor 패키지 — AMD 0.4.3 · NVIDIA 0.6.3 · Intel 0.3.1

이 릴리즈에서 Synology DSM용 GPU 모니터 패키지 세 가지를 다운로드할 수 있습니다. NAS에 장착된 GPU 제조사에 맞는 패키지를 설치하세요.

## AMD GPU Monitor 0.4.3

사용률, VRAM, 온도, 팬, 클럭, 전력을 표시합니다. 칩셋 이름 표시, `amdgpu_top` VRAM 대체 경로, 선택형 **Show Console**을 포함합니다.

## NVIDIA GPU Monitor 0.6.3

NVML을 통해 GPU·VRAM 사용률, NVENC/NVDEC 활동, 온도, 팬, 클럭을 표시하며 `nvidia-smi` 콘솔을 선택해 볼 수 있습니다.

## Intel GPU Monitor 0.3.1

i915 사용률·클럭과 그래픽 칩셋 이름을 표시합니다. 전력은 `intel_gpu_top`으로 대체 수집할 수 있으며, GPU 온도 센서가 없으면 DSM 시스템 온도를 대체값으로 명확히 표시합니다.
