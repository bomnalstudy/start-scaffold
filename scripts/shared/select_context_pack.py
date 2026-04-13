#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--agent", default="codex", choices=["codex", "claude"])
    parser.add_argument("--pack", default="implement")
    parser.add_argument("--as-prompt-block", action="store_true")
    parser.add_argument("--platform", default="unknown")
    parser.add_argument("--is-wsl", default="false")
    parser.add_argument("--environment-pattern", default="native-wsl-linux")
    args = parser.parse_args()

    root = Path(args.root)
    config_path = root / "docs" / "context-packs.json"
    config = json.loads(config_path.read_text(encoding="utf-8"))

    selected = []
    selected.extend(config.get("base", []))
    selected.extend(config.get("agent_adapters", {}).get(args.agent, []))
    selected.extend(config.get("packs", {}).get(args.pack, []))

    deduped = []
    seen = set()
    for item in selected:
        if item not in seen:
            seen.add(item)
            deduped.append(item)

    if args.as_prompt_block:
        print("Use the following context only:")
        print(f"- runtime.platform: {args.platform}")
        print(f"- runtime.isWsl: {str(args.is_wsl).lower()}")
        print(f"- runtime.environmentPattern: {args.environment_pattern}")
        for item in deduped:
            print(f"- {item}")
        print()
        print("Do not load unrelated docs unless blocked.")
        return 0

    print("Context Pack Selection")
    print(f"Agent: {args.agent}")
    print(f"Pack: {args.pack}")
    print(f"Platform: {args.platform}")
    print(f"WSL: {str(args.is_wsl).lower()}")
    print(f"Environment Pattern: {args.environment_pattern}")
    print()
    print("Open these files in order:")
    for idx, item in enumerate(deduped, start=1):
        print(f"{idx}. {item}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
