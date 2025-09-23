#!/usr/bin/env python3
"""
DHCP Pool Checker
-----------------

Validates DHCP pools defined in Hiera YAML files (Foreman/Puppet style).
Prevents bad subnet/mask math from taking down ISC DHCPD.

Checks:
- Each `dhcp::pools` entry must have a valid network + mask combination.
- Optional `gateway` (some networks legitimately have no default GW):
    * If present, it must be inside the subnet and not be network/broadcast.
    * If absent, we WARN by default (configurable).
- All `range` entries must be inside the subnet, ordered (start <= end),
  and must not touch network/broadcast addresses.

Exit code:
- 0 when no errors (warnings never cause non-zero exit unless `--strict`).
- 1 when any ERROR is found (invalid subnet, bad range, bad gateway).
- 2 for usage or environment errors (e.g., folder missing).

CLI flags:
- --require-gateway              -> Treat missing gateway as ERROR (fail).
- --no-warn-missing-gateway      -> Do not warn when gateway is missing.
- --strict                       -> Treat WARNINGS as ERRORS (fail on warnings).
- --dir PATH                     -> Root dir for nodes YAML (default: hieradata/node).

Usage:
  python utils/dhcp-check.py
  python utils/dhcp-check.py --require-gateway
  python utils/dhcp-check.py --no-warn-missing-gateway
  python utils/dhcp-check.py --strict
"""

import argparse
import ipaddress
import sys
from pathlib import Path

import yaml


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Validate DHCP pools in Hiera YAML files.")
    p.add_argument(
        "--dir",
        default="hieradata/node",
        help="Directory containing node YAML files (default: hieradata/nodes)",
    )
    p.add_argument(
        "--require-gateway",
        action="store_true",
        help="Fail when a pool has no gateway (default: warn only).",
    )
    p.add_argument(
        "--no-warn-missing-gateway",
        action="store_true",
        help="Do not warn when a pool has no gateway.",
    )
    p.add_argument(
        "--strict",
        action="store_true",
        help="Treat warnings as errors (non-zero exit if any warnings).",
    )
    return p.parse_args()


def prefixlen_from_mask(mask_str: str) -> int:
    """Convert dotted mask (e.g., 255.255.255.224) to prefix length (/27)."""
    return ipaddress.IPv4Network(f"0.0.0.0/{mask_str}").prefixlen


def validate_pool(file: str, name: str, pool: dict, require_gw: bool, warn_missing_gw: bool):
    """
    Validate one DHCP pool dict.

    Returns:
        errors: list[str]   -> hard failures
        warns:  list[str]   -> soft warnings
    """
    errors, warns = [], []

    # Network + mask must be valid; also verify the provided network equals the subnet base.
    try:
        mask = prefixlen_from_mask(pool["mask"])
        subnet = ipaddress.IPv4Network(f"{pool['network']}/{mask}", strict=True)
    except Exception as e:
        errors.append(f"{file} [{name}]: invalid network/mask → {e}")
        return errors, warns

    if str(subnet.network_address) != pool["network"]:
        errors.append(
            f"{file} [{name}]: network {pool['network']} is not the subnet base "
            f"(should be {subnet.network_address}/{mask})"
        )

    # Gateway is OPTIONAL:
    gw_str = pool.get("gateway")
    if gw_str:
        try:
            gw = ipaddress.ip_address(gw_str)
        except Exception as e:
            errors.append(f"{file} [{name}]: invalid gateway '{gw_str}' → {e}")
            gw = None
        if gw:
            if gw not in subnet:
                errors.append(f"{file} [{name}]: gateway {gw} not in {subnet}")
            elif gw == subnet.network_address or gw == subnet.broadcast_address:
                errors.append(f"{file} [{name}]: gateway {gw} is network/broadcast address")
    else:
        if require_gw:
            errors.append(f"{file} [{name}]: gateway is missing (required by policy)")
        elif not warn_missing_gw:
            pass  # silent
        else:
            warns.append(f"{file} [{name}]: gateway is missing (warning only)")

    # Validate each range.
    for r in pool.get("range", []):
        try:
            start_str, end_str = r.split()
            start = ipaddress.ip_address(start_str)
            end = ipaddress.ip_address(end_str)
        except Exception as e:
            errors.append(f"{file} [{name}]: bad range '{r}' → {e}")
            continue

        if start not in subnet or end not in subnet:
            errors.append(f"{file} [{name}]: range {start}-{end} not inside {subnet}")
        if start > end:
            errors.append(f"{file} [{name}]: range start {start} > end {end}")
        if start in (subnet.network_address, subnet.broadcast_address) or \
           end in (subnet.network_address, subnet.broadcast_address):
            errors.append(f"{file} [{name}]: range {start}-{end} touches network/broadcast")

    return errors, warns


def check_file(path: Path, require_gw: bool, warn_missing_gw: bool):
    """
    Check one YAML file. Returns (errors, warnings).
    """
    try:
        data = yaml.safe_load(path.read_text())
    except yaml.composer.ComposerError as e:
        if "found duplicate anchor" in str(e):
            # Try loading without anchors/aliases by using a simple text replacement
            content = path.read_text()
            # Remove all anchor definitions and references
            import re
            content = re.sub(r'&\w+\s*', '', content)
            content = re.sub(r'\*\w+', '""', content)
            try:
                data = yaml.safe_load(content)
            except Exception as fallback_e:
                return [f"{path}: YAML parse error (even after anchor cleanup) → {fallback_e}"], []
        else:
            return [f"{path}: YAML parse error → {e}"], []
    except Exception as e:
        return [f"{path}: YAML parse error → {e}"], []

    if not data or "dhcp::pools" not in data:
        return [], []

    file_errors, file_warns = [], []
    for name, pool in data["dhcp::pools"].items():
        errs, warns = validate_pool(str(path), name, pool, require_gw, warn_missing_gw)
        file_errors.extend(errs)
        file_warns.extend(warns)

    if not file_errors:
        print(f"✔️  {path}: {len(data['dhcp::pools'])} pool(s) validated OK.")
        if file_warns:
            for w in file_warns:
                print(f"⚠️  {w}")

    return file_errors, file_warns


def main():
    args = parse_args()
    root = Path(args.dir)

    if not root.exists():
        print(f"ERROR: {root} not found")
        sys.exit(2)

    files = sorted(root.glob("*.y*ml"))
    if not files:
        print(f"No YAML files found under {root}")
        sys.exit(0)

    all_errors, all_warns = [], []
    for f in files:
        errs, warns = check_file(f, args.require_gateway, not args.no_warn_missing_gateway)
        all_errors.extend(errs)
        all_warns.extend(warns)

    if all_errors:
        print("\n❌ Errors:")
        for e in all_errors:
            print(" -", e)
        sys.exit(1)

    if all_warns:
        print("\n⚠️  Warnings:")
        for w in all_warns:
            print(" -", w)
        if args.strict:
            sys.exit(1)

    print("\n✅ All DHCP pools look sane.")
    sys.exit(0)


if __name__ == "__main__":
    main()