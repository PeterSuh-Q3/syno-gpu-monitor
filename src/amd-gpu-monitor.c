#define _GNU_SOURCE
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static long read_long(const char *p, long fallback) {
  FILE *f = fopen(p, "r"); long v = fallback;
  if (f) { if (fscanf(f, "%ld", &v) != 1) v = fallback; fclose(f); }
  return v;
}

int main(void) {
  const char *base = "/sys/class/drm/card0/device";
  char p[512];
  long busy, temp, fan, pwm, sclk, mclk, power, total, used;
  snprintf(p, sizeof p, "%s/gpu_busy_percent", base); busy = read_long(p, -1);
  snprintf(p, sizeof p, "%s/hwmon/hwmon1/temp1_input", base); temp = read_long(p, -1);
  snprintf(p, sizeof p, "%s/hwmon/hwmon1/fan1_input", base); fan = read_long(p, -1);
  snprintf(p, sizeof p, "%s/hwmon/hwmon1/pwm1", base); pwm = read_long(p, -1);
  snprintf(p, sizeof p, "%s/hwmon/hwmon1/freq1_input", base); sclk = read_long(p, -1);
  snprintf(p, sizeof p, "%s/hwmon/hwmon1/freq2_input", base); mclk = read_long(p, -1);
  snprintf(p, sizeof p, "%s/hwmon/hwmon1/power1_average", base); power = read_long(p, -1);
  snprintf(p, sizeof p, "%s/mem_info_vram_total", base); total = read_long(p, -1);
  snprintf(p, sizeof p, "%s/mem_info_vram_used", base); used = read_long(p, -1);
  printf("{\"vendor\":\"AMD\",\"gpu_utilization\":%ld,\"temperature_c\":%.1f,\"fan_rpm\":%ld,\"fan_pwm\":%ld,\"gpu_clock_mhz\":%ld,\"memory_clock_mhz\":%ld,\"power_w\":%.3f,\"vram_total_mib\":%ld,\"vram_used_mib\":%ld}\n",
    busy, temp < 0 ? -1.0 : temp / 1000.0, fan, pwm,
    sclk < 0 ? -1 : sclk / 1000000, mclk < 0 ? -1 : mclk / 1000000,
    power < 0 ? -1.0 : power / 1000000.0,
    total < 0 ? -1 : total / 1048576, used < 0 ? -1 : used / 1048576);
  return 0;
}
