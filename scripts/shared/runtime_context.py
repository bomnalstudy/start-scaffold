#!/usr/bin/env python3
import json
import os
import platform


def detect_runtime(agent: str = "unknown") -> dict:
    system = platform.system().lower()
    plat = "unknown"
    if "windows" in system:
        plat = "windows"
    elif "linux" in system:
        plat = "linux"
    elif "darwin" in system:
        plat = "macos"

    is_wsl = False
    if plat == "linux":
        if os.environ.get("WSL_DISTRO_NAME"):
            is_wsl = True
        else:
            try:
                with open("/proc/version", "r", encoding="utf-8") as f:
                    version_text = f.read().lower()
                    is_wsl = "microsoft" in version_text or "wsl" in version_text
            except Exception:
                pass

    shell = os.path.basename(os.environ.get("SHELL", "bash")) or "bash"
    env_pattern = "native-wsl-linux" if plat == "linux" else "powershell-bridged"
    return {
        "agent": agent,
        "platform": plat,
        "isWsl": is_wsl,
        "shell": shell,
        "environmentPattern": env_pattern,
    }


if __name__ == "__main__":
    print(json.dumps(detect_runtime(), ensure_ascii=False))
