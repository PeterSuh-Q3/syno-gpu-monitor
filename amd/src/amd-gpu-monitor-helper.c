#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
  if (argc != 2 || strcmp(argv[1], "postinst") != 0) {
    fputs("invalid action\n", stderr); return 1;
  }
  if (setuid(0) != 0) return 1;
  execl("/var/packages/synology-amd-gpu-monitor/scripts/postinst",
        "postinst", "--root", (char *)0);
  return 1;
}
