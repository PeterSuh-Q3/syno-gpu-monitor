#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, char **argv) {
    if (argc != 2) { fputs("invalid action\n", stderr); return 1; }
    if (setuid(0) != 0) return 1;
    if (strcmp(argv[1], "postinst") == 0) {
        execl("/var/packages/syno-nvidia-gpu-monitor/scripts/postinst", "postinst", "--root", (char *)0);
    } else if (strcmp(argv[1], "console-start") == 0 ||
               strcmp(argv[1], "console-stop") == 0 ||
               strcmp(argv[1], "console-status") == 0) {
        const char *action = argv[1] + 8;
        setenv("GPU_CONSOLE_PKG_ROOT", "/var/packages/syno-nvidia-gpu-monitor", 1);
        setenv("GPU_CONSOLE_TTYD", "/var/packages/syno-nvidia-gpu-monitor/target/bin/ttyd", 1);
        setenv("GPU_CONSOLE_COMMAND", "/var/packages/syno-nvidia-gpu-monitor/target/console/nvidia-smi-console.sh", 1);
        setenv("GPU_CONSOLE_PORT", "17681", 1);
        setenv("GPU_CONSOLE_BASE_PATH", "/nvidia-gpu-console", 1);
        setenv("GPU_CONSOLE_NGINX_LINK", "/etc/nginx/conf.d/dsm.pkg-3rdparty.syno-nvidia-gpu-monitor-console.conf", 1);
        setenv("GPU_CONSOLE_NGINX_CONF", "/var/packages/syno-nvidia-gpu-monitor/target/console/nvidia-console.conf", 1);
        setenv("GPU_CONSOLE_PIDFILE", "/run/syno-nvidia-gpu-monitor-console.pid", 1);
        execl("/var/packages/syno-nvidia-gpu-monitor/target/console/console-control.sh",
              "console-control.sh", action, (char *)0);
    }
    perror("exec");
    return 1;
}
