#!/usr/bin/env bash
# PreToolUse hook: deny reads of likely secrets — SSH private keys, API-token /
# credential files, key/cert material. Exempts encrypted (.age), public (.pub),
# and example/sample/template/dist variants.
#
# Wired in ~/.claude/settings.json as a PreToolUse hook matching "Read|Bash".
# Receives the tool-call JSON on stdin. Exit 2 = deny (stderr shown to Claude).
set -uo pipefail

input="$(cat)"
tool="$(printf '%s' "$input" | jq -r '.tool_name // empty')"

case "$tool" in
  Read) target="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')" ;;
  Bash) target="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')" ;;
  *)    exit 0 ;;
esac

[ -n "$target" ] || exit 0

# Allow-list overrides — these are safe even if they look secret-y.
allow_re='\.(age|pub|example|sample|template|dist)([^A-Za-z0-9]|$)|(^|/)(known_hosts|authorized_keys)([^A-Za-z0-9]|$)|\.ssh/config([^A-Za-z0-9]|$)'

# Sensitive targets.
secret_re='(^|/|[[:space:]])id_(rsa|dsa|ecdsa|ed25519)([^A-Za-z0-9]|$)|\.ssh/id_|\.(pem|key|pfx|p12|pkcs12|keystore|jks|ppk|asc)([^A-Za-z0-9]|$)|(^|/)\.env([^A-Za-z0-9/]|$)|(^|/)\.(netrc|npmrc|pypirc|pgpass|git-credentials)([^A-Za-z0-9]|$)|\.aws/credentials|\.kube/config|gcloud/.*credential|(^|/)(credentials|secrets)([^A-Za-z0-9]|$)'

# Override wins: never block an explicitly-safe variant.
if printf '%s' "$target" | grep -Eiq "$allow_re"; then
  exit 0
fi

if printf '%s' "$target" | grep -Eiq "$secret_re"; then
  cat >&2 <<EOF
Blocked by block-secrets hook: this targets a likely secret (SSH private key,
API token, or credential file):

    $target

If this is intentional, run it yourself in the terminal, or adjust the
allowlist/patterns in ~/.claude/hooks/block-secrets.sh.
EOF
  exit 2
fi

exit 0