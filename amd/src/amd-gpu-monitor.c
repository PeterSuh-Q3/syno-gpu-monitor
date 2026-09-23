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

static int is_amd_card(const char *base) {
  char path[512], vendor[32]; FILE *file;
  snprintf(path, sizeof path, "%s/vendor", base);
  file = fopen(path, "r"); if (!file) return 0;
  if (!fgets(vendor, sizeof vendor, file)) { fclose(file); return 0; }
  fclose(file); return strncmp(vendor, "0x1002", 6) == 0;
}

static long hwmon_long(const char *base, const char *name) {
  char root[192], path[512]; DIR *dir; struct dirent *entry; long value = -1;
  snprintf(root, sizeof root, "%s/hwmon", base);
  dir = opendir(root); if (!dir) return -1;
  while ((entry = readdir(dir)) != NULL) {
    if (strncmp(entry->d_name, "hwmon", 5) != 0) continue;
    if (snprintf(path, sizeof path, "%s/%s/%s", root, entry->d_name, name) >= (int)sizeof path) continue;
    value = read_long(path, -1); if (value >= 0) break;
  }
  closedir(dir); return value;
}

int main(void) {
  char base[128], p[512]; int card;
  long busy, temp, fan, pwm, sclk, mclk, power, total, used;
  for (card = 0; card < 16; ++card) {
    snprintf(base, sizeof base, "/sys/class/drm/card%d/device", card);
    if (is_amd_card(base)) break;
  }
  if (card == 16) {
    puts("{\"vendor\":\"AMD\",\"available\":false,\"reason\":\"No AMD DRM device found\"}");
    return 0;
  }
  snprintf(p, sizeof p, "%s/gpu_busy_percent", base); busy = read_long(p, -1);
  temp = hwmon_long(base, "temp1_input");
  fan = hwmon_long(base, "fan1_input");
  pwm = hwmon_long(base, "pwm1");
  sclk = hwmon_long(base, "freq1_input");
  mclk = hwmon_long(base, "freq2_input");
  power = hwmon_long(base, "power1_average");
  snprintf(p, sizeof p, "%s/mem_info_vram_total", base); total = read_long(p, -1);
  snprintf(p, sizeof p, "%s/mem_info_vram_used", base); used = read_long(p, -1);
  printf("{\"vendor\":\"AMD\",\"available\":true,\"card\":%d,\"gpu_utilization\":%ld,\"temperature_c\":%.1f,\"fan_rpm\":%ld,\"fan_pwm\":%ld,\"gpu_clock_mhz\":%ld,\"memory_clock_mhz\":%ld,\"power_w\":%.3f,\"vram_total_mib\":%ld,\"vram_used_mib\":%ld}\n",
    card,
    busy, temp < 0 ? -1.0 : temp / 1000.0, fan, pwm,
    sclk < 0 ? -1 : sclk / 1000000, mclk < 0 ? -1 : mclk / 1000000,
    power < 0 ? -1.0 : power / 1000000.0,
    total < 0 ? -1 : total / 1048576, used < 0 ? -1 : used / 1048576);
  return 0;
}
