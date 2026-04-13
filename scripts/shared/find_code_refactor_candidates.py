#!/usr/bin/env python3
import argparse
import hashlib
import json
from pathlib import Path


HASHABLE_EXTENSIONS = {".ps1", ".md", ".ts", ".tsx", ".js", ".jsx", ".json", ".yaml", ".yml"}
CLEANUP_ROOTS = ("skills", "scripts", "templates", "harness")


def new_candidate(candidate_type, confidence, path, reason, evidence=None):
    return {
        "type": candidate_type,
        "confidence": confidence,
        "path": path,
        "reason": reason,
        "evidence": evidence or [],
    }


def text_hash(path: Path) -> str:
    content = path.read_text(encoding="utf-8", errors="ignore")
    return hashlib.sha256(content.encode("utf-8")).hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--emit-json", action="store_true")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    candidates = []

    skills_root = root / "skills"
    if skills_root.exists():
        for skill_file in skills_root.rglob("SKILL.md"):
            content = skill_file.read_text(encoding="utf-8", errors="ignore")
            if "Deprecated compatibility alias" in content:
                candidates.append(
                    new_candidate(
                        "deprecated-alias-skill",
                        "high",
                        skill_file.relative_to(root).as_posix(),
                        "Deprecated compatibility alias with a shared replacement exists.",
                        ["Marked as deprecated compatibility alias."],
                    )
                )

    for cleanup_root in CLEANUP_ROOTS:
        base = root / cleanup_root
        if not base.exists():
            continue
        directories = sorted([p for p in base.rglob("*") if p.is_dir()], reverse=True)
        for directory in directories:
            try:
                next(directory.iterdir())
            except StopIteration:
                candidates.append(
                    new_candidate(
                        "empty-folder",
                        "high",
                        directory.relative_to(root).as_posix(),
                        "Empty folder left behind after refactor or rename.",
                    )
                )

    hash_groups = {}
    for file in root.rglob("*"):
        if not file.is_file():
            continue
        rel = file.relative_to(root).as_posix()
        if any(part in {".git", ".graveyard", "worklogs"} for part in file.relative_to(root).parts):
            continue
        if file.suffix.lower() not in HASHABLE_EXTENSIONS:
            continue
        if file.stat().st_size > 8192:
            continue
        try:
            h = text_hash(file)
        except Exception:
            continue
        hash_groups.setdefault(h, []).append(file)

    for group in hash_groups.values():
        if len(group) < 2:
            continue
        rels = [path.relative_to(root).as_posix() for path in group]
        for rel in rels:
            candidates.append(
                new_candidate(
                    "duplicate-content",
                    "medium",
                    rel,
                    "Small file has identical content to another tracked file.",
                    rels,
                )
            )

    sorted_candidates = sorted(candidates, key=lambda item: (item["confidence"], item["path"]))
    summary = {
        "root": str(root),
        "candidateCount": len(candidates),
        "candidates": sorted_candidates,
        "applied": [],
    }

    if args.emit_json:
        print(json.dumps(summary, ensure_ascii=False, indent=2))
        return 0

    print("Code Refactor Candidate Scan")
    print(f"Root: {root}")
    print(f"Candidates: {summary['candidateCount']}")
    print("Applied: 0")
    print()
    if not sorted_candidates:
        print("No candidates.")
        return 0
    for candidate in sorted_candidates:
        print(f"[{candidate['confidence'].upper()}] [{candidate['type']}] {candidate['path']}")
        print(f"  {candidate['reason']}")
        for item in candidate["evidence"]:
            print(f"  - {item}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
