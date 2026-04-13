#!/usr/bin/env python3
import argparse
import shutil
from datetime import datetime
from pathlib import Path


def is_text_file(path: Path) -> bool:
    try:
        path.read_text(encoding="utf-8")
        return True
    except Exception:
        return False


def comment_style(extension: str):
    ext = extension.lower()
    line_hash = {".ps1", ".psm1", ".py", ".rb", ".sh", ".bash", ".yml", ".yaml", ".toml", ".cfg", ".conf", ".env", ".properties", ".txt"}
    line_semicolon = {".ini"}
    block_c = {".js", ".jsx", ".ts", ".tsx", ".java", ".c", ".cpp", ".cs", ".css", ".scss", ".less"}
    block_html = {".html", ".xml", ".svg"}
    if ext in line_hash:
        return {"mode": "line", "prefix": "# ", "suffix": ""}
    if ext in line_semicolon:
        return {"mode": "line", "prefix": "; ", "suffix": ""}
    if ext == ".md":
        return {"mode": "line", "prefix": "[//]: # (", "suffix": ")"}
    if ext in block_c:
        return {"mode": "block", "open": "/*", "close": "*/"}
    if ext in block_html:
        return {"mode": "block", "open": "<!--", "close": "-->"}
    if ext == ".json":
        return {"mode": "disabled", "suffix": ".json.disabled"}
    if ext == ".jsonc":
        return {"mode": "line", "prefix": "// ", "suffix": ""}
    if not ext:
        return {"mode": "disabled", "suffix": ".disabled"}
    return {"mode": "block", "open": "/*", "close": "*/"}


def commented_content(content: str, original_path: str, extension: str) -> str:
    style = comment_style(extension)
    if style["mode"] == "disabled":
        raise ValueError("This file type should be archived as disabled, not commented.")
    header = [
        f"ARCHIVED FROM: {original_path}",
        "THIS FILE HAS BEEN RETIRED AND MUST NOT AFFECT THE CURRENT CODEBASE.",
        "",
    ]
    if style["mode"] == "block":
        lines = [style["open"], *header]
        for line in content.splitlines():
            safe = line.replace("*/", "* /").replace("-->", "- ->")
            lines.append(safe)
        lines.append(style["close"])
        return "\n".join(lines)
    lines = [f"{style['prefix']}{line}{style['suffix']}" for line in header]
    for line in content.splitlines():
        lines.append(f"{style['prefix']}{line}{style['suffix']}")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", required=True)
    parser.add_argument("--path", required=True)
    parser.add_argument("--reason", default="Retired file")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    target = Path(args.path)
    if not target.is_absolute():
        target = (root / target).resolve()

    if not target.exists() or not target.is_file():
        raise ValueError(f"Only individual files can be archived: {args.path}")

    graveyard_files = root / ".graveyard" / "files"
    graveyard_notes = root / ".graveyard" / "notes"
    graveyard_files.mkdir(parents=True, exist_ok=True)
    graveyard_notes.mkdir(parents=True, exist_ok=True)

    relative = target.relative_to(root).as_posix()
    sanitized = relative.replace(":", "__").replace("/", "__").replace("\\", "__")
    extension = target.suffix
    archive_path = graveyard_files / sanitized

    if extension:
        note_base = sanitized[:-len(extension)] + "__" + extension.lstrip(".")
    else:
        note_base = sanitized
    note_path = graveyard_notes / f"{note_base}.md"

    if is_text_file(target):
        content = target.read_text(encoding="utf-8")
        style = comment_style(extension)
        if style["mode"] == "disabled":
            if extension:
                archive_name = sanitized[:-len(extension)] + "__" + extension.lstrip(".") + style.get("suffix", ".disabled")
            else:
                archive_name = sanitized + style.get("suffix", ".disabled")
            archive_path = graveyard_files / archive_name
            archive_path.write_text(content, encoding="utf-8")
        else:
            archive_path.write_text(commented_content(content, relative, extension), encoding="utf-8")
    else:
        if not str(archive_path).endswith(".disabled"):
            archive_path = Path(str(archive_path) + ".disabled")
        shutil.copyfile(target, archive_path)

    target.unlink()

    note_lines = [
        "# Graveyard Note",
        "",
        f"- Original: {relative}",
        f"- Archived: {archive_path.name}",
        f"- Reason: {args.reason}",
        f"- Archived At: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
    ]
    note_path.write_text("\n".join(note_lines), encoding="utf-8")

    print(f"Archived retired file to: {archive_path}")
    print(f"Wrote note to: {note_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
