#include <dirent.h>
#include <stdio.h>
#include <string.h>

#define PATHBUF 512

static long read_long(const char *path, long fallback) {
  FILE *file = fopen(path, "r");
  long value = fallback;
  if (file != NULL) {
    if (fscanf(file, "%ld", &value) != 1) value = fallback;
    fclose(file);
  }
  return value;
}

static int read_text(const char *path, char *out, size_t out_size) {
  FILE *file = fopen(path, "r");
  if (file == NULL || fgets(out, (int)out_size, file) == NULL) {
    if (file != NULL) fclose(file);
    return 0;
  }
  fclose(file);
  out[strcspn(out, "\r\n")] = '\0';
  return 1;
}

static long first_value(const char *base, const char *const *suffixes) {
  char path[PATHBUF];
  int i;
  for (i = 0; suffixes[i] != NULL; i++) {
    long value;
    snprintf(path, sizeof(path), "%s/%s", base, suffixes[i]);
    value = read_long(path, -1);
    if (value >= 0) return value;
  }
  return -1;
}

static long hwmon_value(const char *base, const char *file_name) {
  /* The sysfs root is short; a smaller bounded root also keeps path assembly safe. */
  char root[200];
  char path[PATHBUF];
  DIR *directory;
  struct dirent *entry;
  long value = -1;
  if (strlen(base) + strlen("/hwmon") + 1 > sizeof(root)) return -1;
  strcpy(root, base);
  strcat(root, "/hwmon");
  directory = opendir(root);
  if (directory == NULL) return -1;
  while ((entry = readdir(directory)) != NULL) {
    if (strncmp(entry->d_name, "hwmon", 5) != 0) continue;
    if (strlen(root) + strlen(entry->d_name) + strlen(file_name) + 3 > sizeof(path)) continue;
    strcpy(path, root);
    strcat(path, "/");
    strcat(path, entry->d_name);
    strcat(path, "/");
    strcat(path, file_name);
    value = read_long(path, -1);
    if (value >= 0) break;
  }
  closedir(directory);
  return value;
}

int main(void) {
  int card;
  char base[PATHBUF] = "";
  char path[PATHBUF];
  char vendor[32];
  char device[32] = "unknown";
  long busy, clock, max_clock, temp, power;
  static const char *const busy_paths[] = {"gt_busy_percent", NULL};
  static const char *const clock_paths[] = {"gt_cur_freq_mhz", "gt_act_freq_mhz", NULL};
  static const char *const max_clock_paths[] = {"gt_max_freq_mhz", "gt_RPn_freq_mhz", NULL};

  for (card = 0; card < 16; card++) {
    snprintf(base, sizeof(base), "/sys/class/drm/card%d/device", card);
    snprintf(path, sizeof(path), "%s/vendor", base);
    if (read_text(path, vendor, sizeof(vendor)) && strcmp(vendor, "0x8086") == 0) break;
  }
  if (card == 16) {
    printf("{\"vendor\":\"Intel\",\"available\":false,\"reason\":\"No Intel DRM device found\"}\n");
    return 0;
  }

  snprintf(path, sizeof(path), "%s/device", base);
  (void)read_text(path, device, sizeof(device));
  busy = first_value(base, busy_paths);
  clock = first_value(base, clock_paths);
  max_clock = first_value(base, max_clock_paths);
  temp = hwmon_value(base, "temp1_input");
  power = hwmon_value(base, "power1_average");
  printf("{\"vendor\":\"Intel\",\"available\":true,\"card\":%d,\"device_id\":\"%s\",\"gpu_utilization\":%ld,\"gpu_clock_mhz\":%ld,\"gpu_max_clock_mhz\":%ld,\"temperature_c\":%.1f,\"power_w\":%.3f}\n",
         card, device, busy, clock, max_clock,
         temp < 0 ? -1.0 : temp / 1000.0,
         power < 0 ? -1.0 : power / 1000000.0);
  return 0;
}
