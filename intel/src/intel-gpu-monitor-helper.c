#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv) {
  const char *script;
  const char *action = NULL;
  char *const clean_env[] = {"PATH=/usr/sbin:/usr/bin:/sbin:/bin", "HOME=/", NULL};
  if (argc != 2) return 1;
  if (strcmp(argv[1], "postinst") == 0) script = "/var/packages/synology-intel-gpu-monitor/scripts/postinst";
  else if (strcmp(argv[1], "preuninst") == 0) script = "/var/packages/synology-intel-gpu-monitor/scripts/preuninst";
  else if (strcmp(argv[1], "console-start") == 0) { script = "/var/packages/synology-intel-gpu-monitor/scripts/console-control"; action = "start"; }
  else if (strcmp(argv[1], "console-stop") == 0) { script = "/var/packages/synology-intel-gpu-monitor/scripts/console-control"; action = "stop"; }
  else if (strcmp(argv[1], "console-status") == 0) { script = "/var/packages/synology-intel-gpu-monitor/scripts/console-control"; action = "status"; }
  else if (strcmp(argv[1], "telemetry") == 0) script = "/var/packages/synology-intel-gpu-monitor/scripts/telemetry";
  else return 1;
  if (setuid(0) != 0) return 1;
  /* Only fixed root-owned package scripts and actions are accepted. */
  if (action != NULL) execle(script, script, action, (char *)NULL, clean_env);
  else execle(script, script, "--root", (char *)NULL, clean_env);
  return 1;
}
