#!/usr/bin/env python3
from pathlib import Path

from ai_flow_code_map import map_file


def select_gap_components(root: Path, components: list[dict], memory: dict | None) -> list[dict]:
    if not memory or not memory.get("flows"):
        return components
    covered = covered_flow_text(memory)
    gaps = [component for component in components if has_uncovered_flow_hints(root, component, covered)]
    return gaps


def has_uncovered_flow_hints(root: Path, component: dict, covered: str) -> bool:
    for rel_path in component.get("sampleFiles", []):
        file_map = map_file(root, rel_path)
        hints = [*file_map.get("orchestrators", []), *file_map.get("stages", [])]
        if any(not hint_is_covered(hint, covered) for hint in hints):
            return True
    return False


def covered_flow_text(memory: dict) -> str:
    values = []
    for flow in memory.get("flows", []):
        values.extend([flow.get("name", ""), flow.get("summary", "")])
        for node in flow.get("nodes", []):
            values.extend(
                [
                    node.get("id", ""),
                    node.get("label", ""),
                    node.get("summary", ""),
                    " ".join(node.get("files", [])),
                    " ".join(node.get("evidence", [])),
                ]
            )
    return normalize(" ".join(values))


def hint_is_covered(hint: str, covered: str) -> bool:
    normalized = normalize(hint)
    compact = normalized.replace(" ", "")
    return normalized in covered or compact in covered.replace(" ", "")


def normalize(value: str) -> str:
    return value.lower().replace("_", "-").replace("/", " ").replace(".", " ")
