#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
  const char *script;
  if (argc != 2) return 1;
  if (strcmp(argv[1], "postinst") == 0) script = "postinst";
  else if (strcmp(argv[1], "preuninst") == 0) script = "preuninst";
  else return 1;
  if (setuid(0) != 0) return 1;
  /* Invoke one of two fixed package lifecycle scripts; no caller-supplied path. */
  {
    char path[128];
    snprintf(path, sizeof(path), "/var/packages/synology-intel-gpu-monitor/scripts/%s", script);
    execl(path, path, "--root", (char *)NULL);
  }
  return 1;
}
