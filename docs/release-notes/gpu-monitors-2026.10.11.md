# Synology GPU Monitors — AMD 0.4.5 · NVIDIA 0.6.6 · Intel 0.3.3

The matching GPU vendor was hard to spot in Package Center because several packages shared the same icon. This release gives the three monitors distinct vendor colors and updates their package builds. These packages require DSM 7.2 or later: their x86_64 executables require GLIBC 2.34, which older DSM releases do not provide.

## AMD GPU Monitor 0.4.5

AMD now has a red-backed monitor icon. The package is built with the Debian 12 native x86_64 builder and declares DSM 7.2 as its minimum supported version.

## NVIDIA GPU Monitor 0.6.6

NVIDIA now has a lime-backed monitor icon. The package is built with the Debian 12 native x86_64 builder and declares DSM 7.2 as its minimum supported version.

## Intel GPU Monitor 0.3.3

Intel uses the previous blue NVIDIA monitor icon, leaving the lime icon for NVIDIA. The package is built with the Debian 12 native x86_64 builder and declares DSM 7.2 as its minimum supported version.

The monitors are x86_64 user-space packages and do not install GPU kernel modules. Choose the package matching the GPU in your NAS; the NVIDIA monitor still requires a working NVIDIA driver and NVML.

## SPK SHA-256

- AMD 0.4.5: `47ebe73e0062f604bd36e73c80f4759db93dcaa967b5db02a6fd488d0bc4964f`
- NVIDIA 0.6.6: `914ecde032a2a9f43f3b6d4b7ca031b8a087bdc06450a3fdf9051673632b6cd7`
- Intel 0.3.3: `b85e755f038f3923fa30c382bb7e58388b2921c56692755725782588367fe491`

---

# Synology GPU Monitor 패키지 — AMD 0.4.5 · NVIDIA 0.6.6 · Intel 0.3.3

패키지 센터에서 여러 제조사의 GPU 모니터가 같은 아이콘으로 보여 패키지를 구분하기 어려웠습니다. 이번 릴리즈는 제조사별 아이콘 색을 나누고 패키지를 새로 빌드했습니다. 실행 파일이 GLIBC 2.34를 요구하므로 DSM 7.2 이상이 필요합니다. 이전 DSM은 필요한 GLIBC를 제공하지 않습니다.

## AMD GPU Monitor 0.4.5

AMD 패키지 아이콘에 붉은색 배경을 적용했습니다. Debian 12 네이티브 x86_64 빌더로 패키징했으며, 최소 DSM 버전은 7.2입니다.

## NVIDIA GPU Monitor 0.6.6

NVIDIA 패키지 아이콘에 연두색 배경을 적용했습니다. Debian 12 네이티브 x86_64 빌더로 패키징했으며, 최소 DSM 버전은 7.2입니다.

## Intel GPU Monitor 0.3.3

Intel 패키지에는 기존 파란색 NVIDIA 모니터 아이콘을 배치하고, 연두색 아이콘은 NVIDIA에 사용했습니다. Debian 12 네이티브 x86_64 빌더로 패키징했으며, 최소 DSM 버전은 7.2입니다.

세 모니터는 x86_64 사용자 공간 패키지이며 GPU 커널 모듈을 설치하지 않습니다. NAS의 GPU 제조사에 맞는 패키지를 선택하세요. NVIDIA 모니터는 정상 동작하는 NVIDIA 드라이버와 NVML이 필요합니다.

## SPK SHA-256

- AMD 0.4.5: `47ebe73e0062f604bd36e73c80f4759db93dcaa967b5db02a6fd488d0bc4964f`
- NVIDIA 0.6.6: `914ecde032a2a9f43f3b6d4b7ca031b8a087bdc06450a3fdf9051673632b6cd7`
- Intel 0.3.3: `b85e755f038f3923fa30c382bb7e58388b2921c56692755725782588367fe491`
