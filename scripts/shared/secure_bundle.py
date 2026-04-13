#!/usr/bin/env python3
import argparse
import base64
import hashlib
import hmac
import json
import os
import secrets
import subprocess
import sys
import tempfile
from pathlib import Path


ITERATIONS = 210000


def encode_b64(value: bytes) -> str:
    return base64.b64encode(value).decode("ascii")


def decode_b64(value: str) -> bytes:
    return base64.b64decode(value.encode("ascii"))


def derive_keys(passphrase: str, salt: bytes, iterations: int) -> tuple[bytes, bytes]:
    material = hashlib.pbkdf2_hmac("sha256", passphrase.encode("utf-8"), salt, iterations, dklen=64)
    return material[:32], material[32:]


def get_default_profile(root: Path) -> str:
    project_name = os.environ.get("PROJECT_NAME", "").strip()
    if project_name:
        return project_name.lower()
    return root.name.lower() or "default"


def parse_env_file(path: Path) -> dict[str, str]:
    secrets_map: dict[str, str] = {}
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        separator_index = line.find("=")
        if separator_index < 1:
            continue
        key = line[:separator_index].strip()
        value = line[separator_index + 1 :]
        secrets_map[key] = value
    if not secrets_map:
        raise ValueError(f"No secrets were found in {path}")
    return secrets_map


def render_env_bytes(secrets_map: dict[str, str]) -> bytes:
    lines = [f"{key}={secrets_map[key]}" for key in sorted(secrets_map)]
    text = "\n".join(lines)
    if text:
        text += "\n"
    return text.encode("utf-8")


def get_canonical_payload(bundle: dict) -> str:
    return "\n".join(
        [
            "format=3",
            f"profile={bundle['profile']}",
            f"createdAt={bundle['createdAt']}",
            f"cipher={bundle['cipher']['name']}",
            f"iv={bundle['cipher']['iv']}",
            f"kdf={bundle['kdf']['name']}",
            f"iterations={bundle['kdf']['iterations']}",
            f"salt={bundle['kdf']['salt']}",
            f"payload={bundle['payload']}",
        ]
    )


def compute_tag(auth_key: bytes, bundle: dict) -> str:
    digest = hmac.new(auth_key, get_canonical_payload(bundle).encode("utf-8"), hashlib.sha256).digest()
    return encode_b64(digest)


def run_openssl(cipher_args: list[str], input_bytes: bytes) -> bytes:
    with tempfile.NamedTemporaryFile(delete=False) as input_file:
        input_path = Path(input_file.name)
        input_file.write(input_bytes)
    output_path = input_path.with_suffix(".out")

    try:
        command = ["openssl", "enc", *cipher_args, "-in", str(input_path), "-out", str(output_path)]
        completed = subprocess.run(command, capture_output=True, text=True)
        if completed.returncode != 0:
            stderr = completed.stderr.strip() or "unknown openssl error"
            raise RuntimeError(f"OpenSSL command failed: {stderr}")
        return output_path.read_bytes()
    finally:
        input_path.unlink(missing_ok=True)
        output_path.unlink(missing_ok=True)


def encrypt_payload(plain_bytes: bytes, encryption_key: bytes, iv: bytes) -> bytes:
    return run_openssl(
        ["-aes-256-cbc", "-K", encryption_key.hex(), "-iv", iv.hex()],
        plain_bytes,
    )


def decrypt_payload(cipher_bytes: bytes, encryption_key: bytes, iv: bytes) -> bytes:
    return run_openssl(
        ["-aes-256-cbc", "-d", "-K", encryption_key.hex(), "-iv", iv.hex()],
        cipher_bytes,
    )


def export_bundle(root: Path, profile: str, source: Path, output: Path, passphrase: str) -> None:
    if not source.exists():
        raise FileNotFoundError(f"Secrets source file not found: {source}")

    secrets_map = parse_env_file(source)
    salt = secrets.token_bytes(16)
    iv = secrets.token_bytes(16)
    encryption_key, auth_key = derive_keys(passphrase, salt, ITERATIONS)
    cipher_bytes = encrypt_payload(render_env_bytes(secrets_map), encryption_key, iv)

    bundle = {
        "format": 3,
        "createdAt": __import__("datetime").datetime.now(__import__("datetime").timezone.utc).isoformat().replace("+00:00", "Z"),
        "profile": profile,
        "cipher": {
            "name": "aes-256-cbc",
            "iv": encode_b64(iv),
        },
        "kdf": {
            "name": "pbkdf2-sha256",
            "iterations": ITERATIONS,
            "salt": encode_b64(salt),
        },
        "payload": encode_b64(cipher_bytes),
    }
    bundle["auth"] = {
        "name": "hmac-sha256",
        "tag": compute_tag(auth_key, bundle),
    }

    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps(bundle, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Encrypted project secrets written to: {output}")
    print(f"Profile: {profile}")
    print("Share the passphrase separately from the encrypted bundle.")
    print("If you forget the passphrase, the current vault cannot be recovered. Create a new vault with a new passphrase on the next export.")


def import_bundle(root: Path, profile: str, bundle_path: Path, output: Path, passphrase: str) -> None:
    if not bundle_path.exists():
        raise FileNotFoundError(f"Encrypted secrets bundle not found: {bundle_path}")

    bundle = json.loads(bundle_path.read_text(encoding="utf-8-sig"))
    if int(bundle.get("format", 0)) != 3:
        raise ValueError("Only format 3 bundles are supported in native-wsl-linux mode. Re-export this profile with export-project-secrets first.")

    salt = decode_b64(bundle["kdf"]["salt"])
    iv = decode_b64(bundle["cipher"]["iv"])
    cipher_bytes = decode_b64(bundle["payload"])
    encryption_key, auth_key = derive_keys(passphrase, salt, int(bundle["kdf"]["iterations"]))
    expected_tag = bundle["auth"]["tag"]
    actual_tag = compute_tag(auth_key, bundle)
    if not hmac.compare_digest(expected_tag, actual_tag):
        raise ValueError("Bundle integrity verification failed. Wrong passphrase or modified file. If the passphrase is forgotten, discard this vault and create a new one on the next export.")

    plain_bytes = decrypt_payload(cipher_bytes, encryption_key, iv)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(plain_bytes)
    print(f"Restored local secrets file to: {output}")
    print(f"Profile: {profile}")
    print(f"Load it into your shell with source ./scripts/bash/load-project-secrets.sh --profile {profile}")


def main() -> int:
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest="command", required=True)

    export_parser = subparsers.add_parser("export")
    export_parser.add_argument("--root", required=True)
    export_parser.add_argument("--profile", default="")
    export_parser.add_argument("--source", default="")
    export_parser.add_argument("--output", default="")
    export_parser.add_argument("--passphrase", default="")

    import_parser = subparsers.add_parser("import")
    import_parser.add_argument("--root", required=True)
    import_parser.add_argument("--profile", default="")
    import_parser.add_argument("--bundle-path", default="")
    import_parser.add_argument("--output", default="")
    import_parser.add_argument("--passphrase", default="")

    args = parser.parse_args()
    root = Path(args.root).resolve()
    profile = args.profile or get_default_profile(root)
    passphrase = args.passphrase or os.environ.get("SECRETS_PASSPHRASE", "")
    if not passphrase:
        raise ValueError("Passphrase cannot be empty.")

    try:
        subprocess.run(["openssl", "version"], capture_output=True, check=True)
    except Exception as exc:
        raise RuntimeError("OpenSSL is required for native-wsl-linux secret bundle operations.") from exc

    if args.command == "export":
        source = Path(args.source) if args.source else root / ".local" / "secrets" / f"{profile}.env"
        output = Path(args.output) if args.output else root / "secure-secrets" / f"{profile}.vault.json"
        export_bundle(root, profile, source, output, passphrase)
        return 0

    bundle_path = Path(args.bundle_path) if args.bundle_path else root / "secure-secrets" / f"{profile}.vault.json"
    output = Path(args.output) if args.output else root / ".local" / "secrets" / f"{profile}.env"
    import_bundle(root, profile, bundle_path, output, passphrase)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:
        print(str(exc), file=sys.stderr)
        raise SystemExit(1)
