#!/usr/bin/env zsh

typeset -ga MCP_CONFIG_FILES
MCP_CONFIG_FILES=(
    "$HOME/.dotfiles/zed/settings.json"
    "$HOME/.dotfiles/gemini/settings.json"
    "$HOME/.dotfiles/codewhale/mcp.json"
)

_creds_encrypt_file() {
    local input_file="$1"
    local output_file="$2"
    local key_pub="$HOME/.ssh/id_ed25519.pub"
    local key_priv="$HOME/.ssh/id_ed25519"

    if ! command -v age >/dev/null 2>&1; then
        echo "Error: 'age' utility is not installed."
        echo "You can install it using: sudo apt install age"
        return 1
    fi

    if [[ ! -f "$key_pub" ]]; then
        echo "Error: Public key not found at $key_pub"
        return 1
    fi

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Input file $input_file not found."
        return 1
    fi

    echo "Encrypting $input_file using $key_pub..."

    if age -r "$(cat "$key_pub")" -o "$output_file" "$input_file"; then
        rm -f "$input_file"
        echo "Success! File encrypted to: $output_file"
        echo ""
        echo "To decrypt this file, use the following command:"
        echo " age -d -i $key_priv $output_file > $input_file"
        echo ""
    else
        echo "Error: Encryption failed."
        return 1
    fi
}

_creds_decrypt_file() {
    local input_file="$1"
    local output_file="$2"
    local mode="${3:-600}"
    local key_priv="$HOME/.ssh/id_ed25519"

    if ! command -v age >/dev/null 2>&1; then
        echo "Error: 'age' utility is not installed."
        echo "You can install it using: sudo apt install age"
        return 1
    fi

    if [[ ! -f "$key_priv" ]]; then
        echo "Error: Private key not found at $key_priv"
        return 1
    fi

    if [[ ! -f "$input_file" ]]; then
        echo "Error: Encrypted file $input_file not found."
        return 1
    fi

    echo "Decrypting $input_file using $key_priv..."

    if age -d -i "$key_priv" -o "$output_file" "$input_file"; then
        chmod "$mode" "$output_file"
        echo "Success! File decrypted to: $output_file"
    else
        echo "Error: Decryption failed. Make sure your SSH key is correct and not passphrase protected (or provide it when prompted)."
        return 1
    fi
}

encrypt_secrets() {
    _creds_encrypt_file \
        "$HOME/.dotfiles/custom/env_pass.zsh" \
        "$HOME/.dotfiles/custom/env_pass.zsh.age"
}

decrypt_secrets() {
    _creds_decrypt_file \
        "$HOME/.dotfiles/custom/env_pass.zsh.age" \
        "$HOME/.dotfiles/custom/env_pass.zsh" \
        700
}

encrypt_mcp_secrets() {
    _creds_encrypt_file \
        "$HOME/.dotfiles/custom/mcp_pass.zsh" \
        "$HOME/.dotfiles/custom/mcp_pass.zsh.age"
}

decrypt_mcp_secrets() {
    _creds_decrypt_file \
        "$HOME/.dotfiles/custom/mcp_pass.zsh.age" \
        "$HOME/.dotfiles/custom/mcp_pass.zsh" \
        600
}

_mcp_secret_var_names() {
    local plain_file="$HOME/.dotfiles/custom/mcp_pass.zsh"
    local age_file="$HOME/.dotfiles/custom/mcp_pass.zsh.age"
    local key_priv="$HOME/.ssh/id_ed25519"
    local content=""

    if [[ -f "$plain_file" ]]; then
        content="$(cat "$plain_file")"
    elif [[ -f "$age_file" && -f "$key_priv" ]] && command -v age >/dev/null 2>&1; then
        content="$(age -d -i "$key_priv" "$age_file" 2>/dev/null)" || return 1
    else
        return 1
    fi

    python3 -c '
import re, sys
names = re.findall(r"^\s*(?:export\s+)?([A-Z][A-Z0-9_]*)\s*=", sys.stdin.read(), re.M)
print(" ".join(dict.fromkeys(names)))
' <<< "$content"
}

fill_mcp_secrets() {
    local quiet=0
    if [[ "${1:-}" == "--quiet" || "${1:-}" == "-q" ]]; then
        quiet=1
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        echo "[x] python3 not found; cannot fill MCP secrets"
        return 1
    fi

    python3 - "$quiet" "${MCP_CONFIG_FILES[@]}" <<'PY'
import json
import os
import re
import sys
import tempfile
import shutil
import subprocess

quiet = sys.argv[1] == "1"
files = sys.argv[2:]

ALIASES = {
    "GRAFANA_TOKEN": "GRAFANA_SERVICE_ACCOUNT_TOKEN",
}

PATTERN = re.compile(r"REPLACE_WITH_([A-Z0-9_]+)")


def resolve_secret(key: str) -> str:
    val = os.environ.get(key, "")
    if val:
        return val
    alias = ALIASES.get(key)
    if alias:
        return os.environ.get(alias, "")
    return ""


def configure_codewhale_mcp(path: str, contents: str) -> None:
    if PATTERN.search(contents):
        print("[!] Codewhale MCP configuration deferred: credentials are not fully filled")
        return
    executable = shutil.which("codewhale")
    if not executable:
        print("[!] Codewhale MCP configuration deferred: codewhale is not installed")
        return

    config_path = os.path.expanduser("~/.codewhale/config.toml")
    command = [executable, "--config", config_path, "--no-project-config", "config"]
    try:
        current = subprocess.run(
            command + ["get", "mcp_config_path"], capture_output=True, text=True, timeout=30
        )
        if current.returncode == 0:
            try:
                if json.loads(current.stdout) == path:
                    return
            except ValueError:
                pass

        os.makedirs(os.path.dirname(config_path), mode=0o700, exist_ok=True)
        if os.path.isfile(config_path) and not os.path.islink(config_path):
            fd, backup = tempfile.mkstemp(
                prefix="config.toml.dotfiles-backup.", dir=os.path.dirname(config_path)
            )
            with os.fdopen(fd, "wb") as saved, open(config_path, "rb") as original:
                shutil.copyfileobj(original, saved)
            print(f"[] Existing Codewhale settings backed up to {backup}")

        result = subprocess.run(
            command + ["set", "mcp_config_path", path],
            capture_output=True, text=True, timeout=30,
        )
        if result.returncode == 0:
            print(f"[] Codewhale MCP config set to {path}")
        else:
            print("[x] Could not configure Codewhale MCP path; check codewhale config")
    except (OSError, subprocess.TimeoutExpired):
        print("[x] Could not configure Codewhale MCP path")


def process_file(path: str) -> None:
    if not os.path.isfile(path):
        if not quiet:
            print(f"[!] MCP settings file not found: {path}")
        return

    with open(path, "r", encoding="utf-8") as f:
        original = f.read()

    replaced_count = 0
    unfilled = []

    def repl(match: re.Match) -> str:
        nonlocal replaced_count
        key = match.group(1)
        val = resolve_secret(key)
        if val:
            replaced_count += 1
            return json.dumps(val)[1:-1]
        if key not in unfilled:
            unfilled.append(key)
        return match.group(0)

    updated = PATTERN.sub(repl, original)

    is_codewhale = os.path.abspath(path) == os.path.expanduser("~/.dotfiles/codewhale/mcp.json")
    if is_codewhale:
        # Validate before writing credentials and keep the hydrated file private.
        try:
            if not isinstance(json.loads(updated), dict):
                raise ValueError("expected object")
        except (ValueError, TypeError):
            print("[x] Codewhale MCP configuration deferred: invalid JSON object")
            return
        os.chmod(path, 0o600)

    if updated != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(updated)
        print(f"[] filled {replaced_count} MCP secret(s) in {path}")
    elif not quiet and not unfilled:
        print(f"[] {path} already up to date")

    if unfilled and not quiet:
        missing = ", ".join(f"REPLACE_WITH_{k}" for k in unfilled)
        print(f"[!] unfilled MCP placeholder(s) in {path}: {missing}")

    if is_codewhale:
        configure_codewhale_mcp(path, updated)


for path in files:
    process_file(path)
PY
}

clean_mcp_secrets() {
    if ! command -v python3 >/dev/null 2>&1; then
        echo "[x] python3 not found; cannot clean MCP secrets"
        return 1
    fi

    local var_names
    var_names="$(_mcp_secret_var_names)" || {
        echo "[x] Could not read MCP variable names from mcp_pass.zsh or mcp_pass.zsh.age"
        return 1
    }

    if [[ -z "$var_names" ]]; then
        echo "[!] No MCP secret variables found"
        return 0
    fi

    python3 - "$var_names" "${MCP_CONFIG_FILES[@]}" <<'PY'
import json
import os
import sys

var_names = sys.argv[1].split()
files = sys.argv[2:]

pairs = []
for name in var_names:
    val = os.environ.get(name, "")
    if len(val) >= 6:
        escaped = json.dumps(val)[1:-1]
        pairs.append((escaped, f"REPLACE_WITH_{name}"))
        if val != escaped:
            pairs.append((val, f"REPLACE_WITH_{name}"))

pairs.sort(key=lambda item: len(item[0]), reverse=True)

for path in files:
    if not os.path.isfile(path):
        continue
    with open(path, "r", encoding="utf-8") as f:
        original = f.read()
    updated = original
    count = 0
    for secret, placeholder in pairs:
        if secret in updated:
            count += updated.count(secret)
            updated = updated.replace(secret, placeholder)
    if updated != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(updated)
        print(f"[] redacted {count} MCP secret(s) in {path}")
PY
}

_creds_init() {
    local key_priv="$HOME/.ssh/id_ed25519"
    local env_age="$HOME/.dotfiles/custom/env_pass.zsh.age"
    local mcp_age="$HOME/.dotfiles/custom/mcp_pass.zsh.age"
    local mcp_plain="$HOME/.dotfiles/custom/mcp_pass.zsh"

    if [[ -n "${OP_HOST:-}" ]] && nslookup "$OP_HOST" >/dev/null 2>&1; then
        if [[ -f "$env_age" ]] && source <(age -d -i "$key_priv" "$env_age") "$OP_HOST"; then
            echo "[] creds sourced"
        else
            echo "[x] failed to source creds"
        fi
    else
        echo "[x] Network or DB not reachable."
    fi

    if [[ -f "$mcp_age" ]]; then
        local mcp_decrypted
        if mcp_decrypted="$(age -d -i "$key_priv" "$mcp_age" 2>/dev/null)"; then
            eval "$mcp_decrypted"
            unset mcp_decrypted
            echo "[] mcp creds sourced"
            fill_mcp_secrets --quiet
        else
            echo "[x] failed to source mcp creds"
        fi
    elif [[ -f "$mcp_plain" ]]; then
        echo "[!] custom/mcp_pass.zsh is unencrypted; fill in values and run encrypt_mcp_secrets"
    fi
}

_creds_init
unfunction _creds_init 2>/dev/null
