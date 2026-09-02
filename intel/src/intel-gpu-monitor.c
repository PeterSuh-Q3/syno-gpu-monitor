#define _GNU_SOURCE
#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <linux/perf_event.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <time.h>
#include <unistd.h>

#define PATHBUF 512
struct counter_read { uint64_t value, enabled, running; };

static long read_long(const char *path, long fallback) {
  FILE *file = fopen(path, "r"); long value = fallback;
  if (file != NULL) { if (fscanf(file, "%ld", &value) != 1) value = fallback; fclose(file); }
  return value;
}
static int read_text(const char *path, char *out, size_t size) {
  FILE *file = fopen(path, "r");
  if (file == NULL || fgets(out, (int)size, file) == NULL) { if (file != NULL) fclose(file); return 0; }
  fclose(file); out[strcspn(out, "\r\n")] = '\0'; return 1;
}
static long hwmon_value(const char *base, const char *name) {
  char root[200], path[PATHBUF]; DIR *dir; struct dirent *entry; long value = -1;
  if (strlen(base) + 7 > sizeof(root)) return -1;
  strcpy(root, base); strcat(root, "/hwmon"); dir = opendir(root); if (dir == NULL) return -1;
  while ((entry = readdir(dir)) != NULL) {
    if (strncmp(entry->d_name, "hwmon", 5) != 0) continue;
    if (strlen(root) + strlen(entry->d_name) + strlen(name) + 3 > sizeof(path)) continue;
    strcpy(path, root); strcat(path, "/"); strcat(path, entry->d_name); strcat(path, "/"); strcat(path, name);
    value = read_long(path, -1); if (value >= 0) break;
  }
  closedir(dir); return value;
}
static int perf_open(struct perf_event_attr *attr, pid_t pid, int cpu) {
  return (int)syscall(__NR_perf_event_open, attr, pid, cpu, -1, 0);
}
static int event_config(const char *event, uint64_t *config) {
  char path[PATHBUF], value[64], *hex;
  snprintf(path, sizeof(path), "/sys/bus/event_source/devices/i915/events/%s", event);
  if (!read_text(path, value, sizeof(value))) return 0;
  hex = strstr(value, "0x"); if (hex == NULL) return 0;
  *config = strtoull(hex, NULL, 0); return 1;
}
static int sample_event(int type, uint64_t config, struct counter_read *out) {
  struct perf_event_attr attr; struct timespec pause = {0, 250000000L}; ssize_t got; int fd;
  memset(&attr, 0, sizeof(attr)); attr.type = (unsigned int)type; attr.config = config; attr.size = sizeof(attr);
  attr.disabled = 1; attr.read_format = PERF_FORMAT_TOTAL_TIME_ENABLED | PERF_FORMAT_TOTAL_TIME_RUNNING;
  fd = perf_open(&attr, -1, 0); if (fd < 0) return 0;
  if (ioctl(fd, PERF_EVENT_IOC_RESET, 0) != 0 || ioctl(fd, PERF_EVENT_IOC_ENABLE, 0) != 0) { close(fd); return 0; }
  nanosleep(&pause, NULL); (void)ioctl(fd, PERF_EVENT_IOC_DISABLE, 0);
  got = read(fd, out, sizeof(*out)); close(fd); return got == (ssize_t)sizeof(*out);
}
static long pmu_busy_percent(void) {
  static const char *const engines[] = {"rcs0-busy", "bcs0-busy", "vcs0-busy", "vecs0-busy", NULL};
  struct counter_read sample; uint64_t config; long highest = -1; int type = (int)read_long("/sys/bus/event_source/devices/i915/type", -1), i;
  if (type < 0) return -1;
  for (i = 0; engines[i] != NULL; i++) {
    uint64_t value; long percent;
    if (!event_config(engines[i], &config) || !sample_event(type, config, &sample) || sample.enabled == 0) continue;
    value = sample.value; if (sample.running != 0 && sample.running != sample.enabled) value = value * sample.enabled / sample.running;
    percent = (long)((value * 100ULL) / sample.enabled); if (percent > 100) percent = 100;
    if (highest < percent) highest = percent;
  }
  return highest;
}
static long debugfs_frequency(const char *label) {
  FILE *file = fopen("/sys/kernel/debug/dri/0/i915_frequency_info", "r"); char line[256]; long value = -1;
  if (file == NULL) return -1;
  while (fgets(line, sizeof(line), file) != NULL) if (strncmp(line, label, strlen(label)) == 0 && sscanf(line + strlen(label), "%ld", &value) == 1) break;
  fclose(file); return value;
}
int main(void) {
  int card; char base[PATHBUF] = "", path[PATHBUF], vendor[32], device[32] = "unknown";
  long busy, clock, max_clock, temp, power;
  for (card = 0; card < 16; card++) {
    snprintf(base, sizeof(base), "/sys/class/drm/card%d/device", card); snprintf(path, sizeof(path), "%s/vendor", base);
    if (read_text(path, vendor, sizeof(vendor)) && strcmp(vendor, "0x8086") == 0) break;
  }
  if (card == 16) { puts("{\"vendor\":\"Intel\",\"available\":false,\"reason\":\"No Intel DRM device found\"}"); return 0; }
  snprintf(path, sizeof(path), "%s/device", base); (void)read_text(path, device, sizeof(device));
  busy = pmu_busy_percent(); clock = debugfs_frequency("Actual freq:"); max_clock = debugfs_frequency("Max freq:");
  temp = hwmon_value(base, "temp1_input"); power = hwmon_value(base, "power1_average");
  printf("{\"vendor\":\"Intel\",\"available\":true,\"card\":%d,\"device_id\":\"%s\",\"gpu_utilization\":%ld,\"gpu_clock_mhz\":%ld,\"gpu_max_clock_mhz\":%ld,\"temperature_c\":%.1f,\"power_w\":%.3f}\n", card, device, busy, clock, max_clock, temp < 0 ? -1.0 : temp / 1000.0, power < 0 ? -1.0 : power / 1000000.0);
  return 0;
}
